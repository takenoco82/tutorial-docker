from flask import Blueprint, jsonify
from server.exceptions import ValidationError

app = Blueprint('get_fizzbuzz', __name__)


@app.route('/fizzbuzz/<int:n>', methods=['GET'])
def get_fizzbuzz(n: int):
    validate(n)
    response = get_response(fizzbuzz(n))
    return jsonify(response), 200


def validate(n: int):
    if n < 1:
        message = {
            "code": "E001",
            "message": f"`{n}` is invalid value. must be larger than `0`."
        }
        raise ValidationError([message])


def get_response(fizzbuzz: str):
    return {"fizzbuzz": fizzbuzz}


def fizzbuzz(n: int) -> str:
    if n % 15 == 0:
        return "FizzBuzz"
    elif n % 3 == 0:
        return "Fizz"
    elif n % 5 == 0:
        return "Buzz"
    else:
        return str(n)
