FROM python:3.7.0-alpine3.7

#
# Directory structure
#
# /user/src/
#   app/
#     server/
#       api/
#       ...
#     tests/
#       ...
#     run.py
#   Pipfile
#   Pipfile.lock
#
WORKDIR /usr/src
ENV PYTHONPATH=/usr/src/app:$PYTHONPATH

# ライブラリをインストール
COPY ./Pipfile ./Pipfile.lock ./
RUN pip install --upgrade pip && pip install --no-cache-dir pipenv
RUN pipenv install --system

# ソースをコピー
WORKDIR /usr/src/app
COPY src/ ./

# テスト時のみ、開発環境用のライブラリをインストール
ARG TESTING
RUN if [ "${TESTING}" == "True" ]; then \
    pipenv install --dev --system; \
fi

CMD [ "python", "./run.py" ]
