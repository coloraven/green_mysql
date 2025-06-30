# mysql_green
绿色版mysql制作
## 别人造de轮子：
https://www.cnblogs.com/lingdurebing/p/114514_.html
https://zhuanlan.zhihu.com/p/707940637
## 解压官方程序压缩包
解压`mysql-noinstall-5.0.15-win32.zip`（官方下载地址:https://cdn.mysql.com/archives/mysql-5.0/mysql-noinstall-5.0.15-win32.zip），下载其他版本：`https://downloads.mysql.com/archives/community/`
最后一个支持xp的mysql版本是`5.0.27`。

## 将本项目中stop.bat、start.bat、my.ini、init.sql四个文件放在解压好的根目录中

## 启动mysql服务
执行`start.bat`，这会保持一个cmd窗口不能关掉，如果关掉，mysql服务就停止了，而且没有保存的数据可能丢失，不要轻易关闭此窗口。
## 正确停止mysql服务
执行`stop.bat`，这会优雅的停止mysql服务。

## 配套并发写测试代码
```python
import random
import threading
import time

import pymysql

# ================== 配置 ==================
DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 3306,
    'user': 'root',
    'password': '',  # 如果设置了密码，请填写
    'database': 'main',
    'charset': 'utf8'
}

TABLE_NAME = 'data'
NUM_THREADS = 50     # 线程数量
ITEMS_PER_THREAD = 1000  # 每个线程插入的数据量

# ================== 时间格式化函数 ==================
def format_time(timestamp):
    return f"{time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(timestamp))}.{int((timestamp % 1) * 1e6):06d}"

# ================== 初始化数据库和表 ==================
def init_db():
    # 先连接到默认数据库（比如 mysql），用于执行创建 testdb 数据库的操作
    temp_config = DB_CONFIG.copy()
    temp_config['database'] = 'mysql'  # 使用 mysql 系统数据库作为临时连接目标

    try:
        conn = pymysql.connect(**temp_config)
        cur = conn.cursor()

        # 创建目标数据库 testdb（如果不存在）
        cur.execute(f"""
            CREATE DATABASE IF NOT EXISTS {DB_CONFIG['database']} 
            CHARACTER SET utf8 
            COLLATE utf8_unicode_ci
        """)
        conn.commit()
        print("✅ 数据库 testdb 已创建或已存在")

        # 关闭当前连接，重新连接到 testdb
        conn.close()
        conn = pymysql.connect(**DB_CONFIG)
        cur = conn.cursor()

        # 在 testdb 中创建数据表（如果不存在）
        cur.execute(f"""
            CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
                id INT AUTO_INCREMENT PRIMARY KEY,
                thread_id INT,
                value1 VARCHAR(255),
                value2 VARCHAR(255),
                create_time DATETIME
            )
        """)
        conn.commit()
        print("✅ 表已创建或已存在")

    except pymysql.MySQLError as e:
        print(f"❌ 初始化数据库失败: {e}")
        raise
    finally:
        if conn:
            conn.close()

# ================== 每个线程执行的任务 ==================
def worker(thread_id):
    connection = pymysql.connect(**DB_CONFIG)
    cursor = connection.cursor()

    for i in range(ITEMS_PER_THREAD):
        val1 = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=8))
        val2 = ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ', k=8))
        now = time.strftime('%Y-%m-%d %H:%M:%S')

        sql = f"INSERT INTO {TABLE_NAME} (thread_id, value1, value2, create_time) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (thread_id, val1, val2, now))

        # 打印插入信息
        ts = format_time(time.time())
        # print(f"[线程 {thread_id}] 插入第 {i+1} 条: ({val1}, {val2}) @ {ts}")

        # 模拟写入延迟
        time.sleep(0.01)

    connection.commit()
    cursor.close()
    connection.close()

# ================== 主程序入口 ==================
if __name__ == '__main__':
    # 初始化数据库和表
    init_db()

    # 启动多线程
    threads = []
    start_time = time.time()

    for tid in range(NUM_THREADS):
        t = threading.Thread(target=worker, args=(tid,))
        t.start()
        threads.append(t)

    # 等待所有线程完成
    for t in threads:
        t.join()

    end_time = time.time()
    total_items = NUM_THREADS * ITEMS_PER_THREAD
    print(f"\n🏁 总共插入 {total_items} 条记录，耗时 {end_time - start_time:.2f} 秒")

    # 查询总数验证
    conn = pymysql.connect(**DB_CONFIG)
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {TABLE_NAME}")
        count = cur.fetchone()[0]
        print(f"📊 实际表中记录数: {count}")
```
