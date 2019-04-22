include .env
SANDBOX_TAG_TESTING := ${SANDBOX_TAG}-testing

clean:
	# 停止＆削除 (コンテナ・ネットワーク・ボリューム)
	docker-compose down -v
	# サンプルデータ (world.sql) の取得
	rm config/mysql/initdb.d/world.sql
	curl https://downloads.mysql.com/docs/world.sql.gz | \
		gzip -d > config/mysql/initdb.d/world.sql

init: clean
	docker-compose up -d

stop:
	docker-compose stop
	docker-compose rm -f

build:
	docker build --build-arg TESTING=${TESTING} -t ${SANDBOX_REPOSITORY}:${SANDBOX_TAG} .

run: stop build
	docker-compose up -d

test:
	docker build --build-arg TESTING=True -t ${SANDBOX_REPOSITORY}:${SANDBOX_TAG_TESTING} .
	docker run --rm ${SANDBOX_REPOSITORY}:${SANDBOX_TAG_TESTING} \
		nosetests -v --nologcapture /usr/src/app/tests
