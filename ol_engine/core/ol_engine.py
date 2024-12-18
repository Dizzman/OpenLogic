import logging
import psycopg2
class DatabaseConfig:
       dbname="postgres"
       user="postgres"
       password="password"
       host="localhost"
       port="5432"


class OLEngineCore:
    def __init__(self):
        self.conn = psycopg2.connect(
            dbname="ol_postgres_db",
            user="postgres",
            password="cznixo",
            host="localhost",
            port="5432"
        )
        self.cur = self.conn.cursor()
        self.cur.execute("SELECT version();")
        logging.info(self.cur.fetchone())
    def create_inventory_tables(self):
        
        pass
    def remote_all_and_create_core_tables(self):
        pass

