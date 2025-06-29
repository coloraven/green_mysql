-- 切换到系统数据库
USE mysql;

-- 设置 root 用户密码（适用于 MySQL 5.x）
UPDATE user SET password = PASSWORD('') WHERE user = 'root';

-- 将 root 用户的 Host 改为 '%'，允许从任意 IP 登录
UPDATE user SET host = '%' WHERE user = 'root';

-- 删除匿名用户
DELETE FROM user WHERE user = '';

-- 删除测试/空数据库权限记录
DELETE FROM db WHERE db = 'main' OR db = '';

-- 刷新权限
FLUSH PRIVILEGES;

-- 创建主数据库
CREATE DATABASE IF NOT EXISTS main;