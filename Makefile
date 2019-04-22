include .env
FIZZBUZZ_TAG_TESTING := ${FIZZBUZZ_TAG}-testing

clean_db:
	# 停止＆削除 (コンテナ・ネットワーク・ボリューム)
	docker-compose down -v
	# サンプルデータ (world.sql) の取得
	# rm config/mysql/initdb.d/world.sql
	# curl https://downloads.mysql.com/docs/world.sql.gz | \
	# 	gzip -d > config/mysql/initdb.d/world.sql

init_db: clean_db
	docker-compose up -d

stop:
	docker ps --filter=ancestor=${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG} -q | xargs docker stop

build:
	docker build --build-arg TESTING=${TESTING} -t ${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG} .

run: stop build
	docker run -d -p 8080:8080 --rm ${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG}

test:
	docker build --build-arg TESTING=True -t ${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG_TESTING} .
	docker run --rm ${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG_TESTING} \
		nosetests -v --nologcapture /usr/src/app/tests

clean: stop
	docker ps --filter=ancestor=${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG} -a -q | xargs docker rm -f

push: build
	docker login
	docker tag ${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG} ${FIZZBUZZ_REPOSITORY}:latest
	docker push ${FIZZBUZZ_REPOSITORY}:${FIZZBUZZ_TAG}
	docker push ${FIZZBUZZ_REPOSITORY}:latest
