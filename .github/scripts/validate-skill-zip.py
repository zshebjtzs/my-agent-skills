#!/usr/bin/env python3
"""Download and safely validate a text-only Skill ZIP attachment."""

import json
import os
import re
import stat
import sys
import tempfile
import urllib.parse
import urllib.request
import zipfile

MAX_ARCHIVE_BYTES = 10 * 1024 * 1024
MAX_TOTAL_BYTES = 10 * 1024 * 1024
MAX_FILE_BYTES = 2 * 1024 * 1024
MAX_FILES = 100
ALLOWED_REDIRECT_HOSTS = {
    "github.com",
    "objects.githubusercontent.com",
    "release-assets.githubusercontent.com",
    "github-releases.githubusercontent.com",
    "private-user-images.githubusercontent.com",
    "user-images.githubusercontent.com",
}


class ValidationError(Exception):
    pass


class SafeRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parsed = urllib.parse.urlparse(newurl)
        if parsed.scheme != "https" or parsed.hostname not in ALLOWED_REDIRECT_HOSTS:
            raise ValidationError("附件下载发生了不受信任的重定向，已拒绝。")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def write_output(key, value):
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        safe = str(value).replace("\r", " ").replace("\n", " ").replace("%", "%25")
        with open(output_path, "a", encoding="utf-8") as output:
            output.write(key + "=" + safe + "\n")


def download_archive(url, destination):
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme != "https" or parsed.hostname != "github.com":
        raise ValidationError("ZIP 附件必须来自 GitHub。")
    if not parsed.path.startswith("/user-attachments/files/") or not parsed.path.lower().endswith(".zip"):
        raise ValidationError("只接受 GitHub Issue 上传的 .zip 附件链接。")

    opener = urllib.request.build_opener(SafeRedirectHandler())
    request = urllib.request.Request(url, headers={"User-Agent": "my-agent-skills-validator/1.0"})
    with opener.open(request, timeout=30) as response:
        final_url = urllib.parse.urlparse(response.geturl())
        if final_url.scheme != "https" or final_url.hostname not in ALLOWED_REDIRECT_HOSTS:
            raise ValidationError("附件最终下载地址不受信任，已拒绝。")
        length = response.headers.get("Content-Length")
        if length and int(length) > MAX_ARCHIVE_BYTES:
            raise ValidationError("ZIP 压缩包超过 10 MB 限制。")
        total = 0
        with open(destination, "wb") as output:
            while True:
                chunk = response.read(64 * 1024)
                if not chunk:
                    break
                total += len(chunk)
                if total > MAX_ARCHIVE_BYTES:
                    raise ValidationError("ZIP 压缩包超过 10 MB 限制。")
                output.write(chunk)
    if os.path.getsize(destination) < 4:
        raise ValidationError("上传文件为空或不是有效 ZIP。")


def safe_member_path(raw):
    if not raw or "\x00" in raw or "\\" in raw:
        raise ValidationError("ZIP 中存在空路径、NUL 字符或反斜杠路径。")
    if raw.startswith("/") or re.match(r"^[A-Za-z]:", raw):
        raise ValidationError("ZIP 中存在绝对路径或 Windows 盘符路径。")
    parts = raw.rstrip("/").split("/")
    if not parts or any(part in ("", ".", "..") for part in parts):
        raise ValidationError("ZIP 中存在不安全的路径段。")
    if any(":" in part or any(ord(ch) < 32 for ch in part) for part in parts):
        raise ValidationError("ZIP 中存在非法文件名。")
    if any(part.casefold() == ".git" for part in parts):
        raise ValidationError("Skill ZIP 不允许包含 .git 目录。")
    if not re.fullmatch(r"[A-Za-z0-9_.@+-]+(?:/[A-Za-z0-9_.@+-]+)*", "/".join(parts)):
        raise ValidationError("文件路径只能包含字母、数字、下划线、点、@、+、- 和目录分隔符。")
    return "/".join(parts)


def read_zip(archive_path):
    files = {}
    folded_paths = set()
    declared_total = 0
    actual_total = 0

    with zipfile.ZipFile(archive_path, "r") as archive:
        members = archive.infolist()
        if not members:
            raise ValidationError("ZIP 压缩包为空。")

        for info in members:
            path = safe_member_path(info.filename)
            mode = (info.external_attr >> 16) & 0xFFFF
            file_type = stat.S_IFMT(mode)

            if info.is_dir():
                continue
            if file_type == stat.S_IFLNK:
                raise ValidationError("ZIP 中包含符号链接，已拒绝。")
            if file_type not in (0, stat.S_IFREG):
                raise ValidationError("ZIP 中包含特殊文件类型，已拒绝。")
            if info.flag_bits & 0x1:
                raise ValidationError("不支持加密 ZIP，请上传未加密的压缩包。")
            if "__MACOSX/" in path or path.endswith("/.DS_Store") or path == ".DS_Store":
                continue

            normalized = path.casefold()
            if normalized in folded_paths:
                raise ValidationError("ZIP 中存在重复或大小写冲突的文件路径：" + path)
            folded_paths.add(normalized)

            if info.file_size > MAX_FILE_BYTES:
                raise ValidationError("单个文件超过 2 MB 限制：" + path)
            declared_total += info.file_size
            if declared_total > MAX_TOTAL_BYTES:
                raise ValidationError("解压后的文件总大小超过 10 MB 限制。")
            if len(files) >= MAX_FILES:
                raise ValidationError("Skill 最多允许 100 个文件。")

            chunks = []
            actual_size = 0
            with archive.open(info, "r") as source:
                while True:
                    chunk = source.read(64 * 1024)
                    if not chunk:
                        break
                    actual_size += len(chunk)
                    actual_total += len(chunk)
                    if actual_size > MAX_FILE_BYTES or actual_total > MAX_TOTAL_BYTES:
                        raise ValidationError("解压后的文件内容超过大小限制：" + path)
                    chunks.append(chunk)
            if actual_size != info.file_size:
                raise ValidationError("ZIP 文件大小信息异常：" + path)

            content_bytes = b"".join(chunks)
            if b"\x00" in content_bytes:
                raise ValidationError("当前版本只接受 UTF-8 文本文件，检测到二进制内容：" + path)
            try:
                content = content_bytes.decode("utf-8-sig")
            except UnicodeDecodeError:
                raise ValidationError("当前版本只接受 UTF-8 文本文件：" + path)

            files[path] = content

    if not files:
        raise ValidationError("ZIP 中没有可提交的文本文件。")

    skill_files = [path for path in files if path == "SKILL.md" or path.endswith("/SKILL.md")]
    if len(skill_files) != 1:
        raise ValidationError("ZIP 必须且只能包含一个 SKILL.md。")

    skill_path = skill_files[0]
    if skill_path != "SKILL.md":
        top_levels = {path.split("/", 1)[0] for path in files}
        if len(top_levels) != 1 or "/" not in skill_path:
            raise ValidationError("SKILL.md 必须位于 ZIP 根目录，或唯一的顶层项目目录中。")
        root = next(iter(top_levels))
        if not skill_path.startswith(root + "/"):
            raise ValidationError("ZIP 项目根目录结构不一致。")
        files = {path[len(root) + 1:]: content for path, content in files.items()}
        if "SKILL.md" not in files:
            raise ValidationError("无法识别 ZIP 内的 Skill 根目录。")

    if not files["SKILL.md"].strip():
        raise ValidationError("SKILL.md 不能为空。")

    return files


def main():
    if len(sys.argv) != 3:
        raise ValidationError("验证器参数错误。")
    url, manifest_path = sys.argv[1], sys.argv[2]

    with tempfile.TemporaryDirectory(prefix="skill-zip-") as temp_dir:
        archive_path = os.path.join(temp_dir, "submission.zip")
        download_archive(url, archive_path)
        files = read_zip(archive_path)

    manifest = {
        "files": [{"path": path, "content": content} for path, content in sorted(files.items())],
        "file_count": len(files),
        "total_bytes": sum(len(content.encode("utf-8")) for content in files.values()),
    }
    with open(manifest_path, "w", encoding="utf-8") as output:
        json.dump(manifest, output, ensure_ascii=False)
    write_output("file_count", manifest["file_count"])
    write_output("total_bytes", manifest["total_bytes"])
    print("ZIP validation passed: " + str(manifest["file_count"]) + " UTF-8 text files.")


if __name__ == "__main__":
    try:
        main()
    except (ValidationError, zipfile.BadZipFile, RuntimeError, OSError, ValueError) as error:
        message = str(error) or "ZIP 验证失败。"
        write_output("validation_error", message)
        print("Validation error: " + message, file=sys.stderr)
        sys.exit(1)
