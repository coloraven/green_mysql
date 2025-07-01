@echo off
echo 正在尝试优雅关闭 MySQL 服务...,默认无密码，直接回车！

:: 进入 bin 目录
cd /d "%~dp0%bin"

:: 执行关闭命令
mysqladmin -u root -p shutdown

echo MySQL 已成功关闭。
pause