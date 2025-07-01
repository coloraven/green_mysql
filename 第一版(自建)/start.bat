@echo off
:: 设置当前目录为根目录
cd /d "%~dp0%"


:: 判断是否已经初始化过（通过是否存在 mysql 数据库目录）
if not exist "data\main" (
    echo 加载自定义初始化脚本...
    bin\mysqld-nt --bootstrap ^
        --datadir=data ^
        --basedir=. ^
        --language=english ^
        < init.sql
)
echo 正在启动 MySQL 服务...
bin\mysqld ^
    --console ^
    --basedir=. ^
    --datadir=data ^
    --language=english