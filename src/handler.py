"""
Lambda handler đơn giản để demo CI/CD.

- Thư viện `requests` KHÔNG nằm trong zip code, mà nằm trong Lambda Layer
  (được GitHub Actions build từ src/requirements.txt và publish riêng).
- Mỗi lần sửa file này và push lên main, pipeline sẽ tự deploy lại.
"""

import json
import os

import requests  # được cung cấp bởi Lambda Layer


APP_VERSION = "1.0.0"


def build_message(event: dict) -> dict:
    name = (event or {}).get("name", "world")
    return {
        "message": f"Hello, {name}!",
        "app_version": APP_VERSION,
        "requests_version": requests.__version__,
        "function_name": os.environ.get("AWS_LAMBDA_FUNCTION_NAME", "local"),
    }


def lambda_handler(event, context):
    body = build_message(event)
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
