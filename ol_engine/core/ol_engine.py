import sys
sys.path.append('../')
import logging
import psycopg2
from  config.db_config import DatabaseConfig


class OLEngineCore:
    def __init__(self):
        self.conn = psycopg2.connect(
            dbname=DatabaseConfig.dbname,
            user=DatabaseConfig.user,
            password=DatabaseConfig.password,
            host=DatabaseConfig.host,
            port=DatabaseConfig.port
        )
        self.cur = self.conn.cursor()
        self.cur.execute("SELECT version();")
        logging.info(self.cur.fetchone())
    def create_inventory_tables(self):

        pass
    def remote_all_and_create_core_tables(self):
        pass

