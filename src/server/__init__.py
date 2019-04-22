from flask import Flask

from server.controller import get_fizzbuzz
from server.error_handler import validation_error_handler
from server.exceptions import ValidationError

apis = [
    get_fizzbuzz.app,
]

app = Flask(__name__)

# Blueprint の登録
for api in apis:
    app.register_blueprint(api, url_prefix="/v1")

# エラーハンドラー
app.register_error_handler(ValidationError, validation_error_handler)
