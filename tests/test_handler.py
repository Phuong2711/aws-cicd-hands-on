import json
import sys
from pathlib import Path

# Cho phép import `handler` từ thư mục src/
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

import handler  # noqa: E402


def test_default_message():
    resp = handler.lambda_handler({}, None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["message"] == "Hello, world!"
    assert body["app_version"] == handler.APP_VERSION


def test_message_with_name():
    resp = handler.lambda_handler({"name": "Phuong"}, None)
    body = json.loads(resp["body"])
    assert body["message"] == "Hello, Phuong!"
    assert "requests_version" in body
