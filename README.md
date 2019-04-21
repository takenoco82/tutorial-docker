# tutorial-docker

## 概要
- Docker の紹介するためのサンプルプロジェクトです。

## MySQL で複数のバージョンを切り替える
1. MySQL 5.7 で サンプルSQLを実行する (8.0用は失敗する)
2. MySQL 8.0 にバージョンを切り替えて、再度、サンプルSQLを実行する (8.0用も成功する)

### バージョンを確認する
``` sh
docker exec tutorial-docker_mysql_1 mysql --version
```

### サンプルSQL
``` sql
/*
 * 大陸ごとに人口の多い国 トップ5
 */

-- 5.7用
set @row_num:=0;
set @group_column:=null;
set @prev_value:=null;

select
    Continent,
    PopulationRank,
    Name,
    Population
from (
    select
        Continent,
        Name,
        Population,
        case
            when @group_column != Continent then @row_num:=1
            when @prev_value = Population then @row_num
            else @row_num:=@row_num+1
        end PopulationRank,
        @group_column:=Continent,
        @prev_value:=Population
    from country
    order by Continent, Population DESC
) country_population
where PopulationRank <= 5
;

-- 8.0用 (5.7では使えない)
select
    *
from (
    select
        Continent,
        rank() over(partition by Continent order by Population desc) as PopulationRank,
        Name,
        Population
    from country
) country_population
where PopulationRank <= 5
;
```
