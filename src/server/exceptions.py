class ValidationError(Exception):
    def __init__(self, messages):
        self.status_code = 400
        self.messages = messages
