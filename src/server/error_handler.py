from flask import jsonify


def validation_error_handler(error):
    response = {"errors": error.messages}
    return jsonify(response), error.status_code
