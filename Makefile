include .env

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

run: stop
	docker-compose up -d
