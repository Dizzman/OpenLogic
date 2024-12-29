import sys
sys.path.append('../')
import logging
import psycopg2
from  config.db_config import DatabaseConfig


class OLEngineCore:
    def __init__(self,config_db:DatabaseConfig):
        self.config_db = config_db
        try:
            self.conn = psycopg2.connect(
                user=config_db.user,
                password=config_db.password,
                host=config_db.host,
                port=config_db.port
            )
            self.conn.autocommit = True
            self.cur = self.conn.cursor()
            self.cur.execute("SELECT version();")
            logging.info(self.cur.fetchone())
            self.list_databases()
        except psycopg2.Error as e:
            logging.error(f"Error connecting to the database: {e}")
            raise

    def get_currdb(self):
        if self.conn is not None:
            curdb = self.conn.get_dsn_parameters()['dbname']
        return curdb
    def connect_to_database(self,project_name):
        try:
            if  self.conn is not None:
                curdb=self.conn.get_dsn_parameters()['dbname']
                logging.info(f"Current connect: {curdb}")
                logging.info(f"Close opened connect")
                self.conn.close()
            # Устанавливаем соединение с новой базой данных
            self.conn= psycopg2.connect(
                user=self.config_db.user,
                password=self.config_db.password,
                host=self.config_db.host,
                port=self.config_db.port,
                database=project_name
            )
            self.cur = self.conn.cursor()
            logging.info(f"Connected to : {project_name}")


        except Exception as e:
            logging.error(f"Error to connect {project_name}: {e}")
            return None
    def list_databases(self):
        """List all databases in the PostgreSQL instance."""
        try:
            self.cur.execute("SELECT datname FROM pg_database WHERE datistemplate = false;")
            databases = self.cur.fetchall()
            logging.info(f"Databases in the system: {databases}")
            return databases
        except psycopg2.Error as e:
            logging.error(f"Error while listing databases: {e}")
            return []

    def create_projectDB(self, project_name):
        """Creates a new database for the project."""
        try:

            self.cur.execute(f"CREATE DATABASE {project_name};")
            self.conn.commit()
            logging.info(f"Database '{project_name}' successfully created.")

            self.cur.close()
            self.conn.close()

            self.conn = psycopg2.connect(
                dbname=project_name,
                user=self.config_db.user,
                password=self.config_db.password,
                host=self.config_db.host,
                port=self.config_db.port
            )
            self.cur = self.conn.cursor()
            logging.info(f"Connected to the newly created database '{project_name}'.")


            self.conn.commit()
            logging.info(f"Table 'projects' created in database '{project_name}'.")

        except psycopg2.Error as e:
            logging.error(f"Error while creating the project database: {e}")

    def remove_projectDB(self, project_name):
        """Removes the project database."""
        try:

            self.cur.execute(f"DROP DATABASE IF EXISTS {project_name};")
            self.conn.commit()
            logging.info(f"Database '{project_name}' successfully removed.")
        except psycopg2.Error as e:
            logging.error(f"Error while removing the project database: {e}")

    def create_scenario(self, scenario_name:str,comment:str):
        """Creates a table for storing scenarios and adds a new scenario."""
        try:
            self.cur.execute("""
                CREATE TABLE IF NOT EXISTS T_Scenarios (
                    id serial PRIMARY KEY,          
                    scenario_name TEXT,     
                    is_active INTEGER DEFAULT 0 UNIQUE,        
                    comment TEXT                    
                );
            """)
            self.cur.execute("""
                INSERT INTO T_Scenarios (scenario_name, comment) 
                VALUES (%s, %s);
            """, (scenario_name, comment))
            self.conn.commit()
            logging.info(f"Scenario with ID {scenario_name} successfully created.")
        except psycopg2.Error as e:
            logging.error(f"Error while creating scenario: {e}")

    def getid_current_scenario(self):
        self.cur.execute(f"select id from T_Scenarios WHERE is_active = 1")
        ids = self.cur.fetchall()
        return [id[0] for id in ids][0]
    def setcurrent_scenario(self,project_name, scenario_name: str):
        self.cur.execute(f"UPDATE T_Scenarios SET is_active = 0 WHERE is_active = 1")
        self.cur.execute(f"UPDATE T_Scenarios SET is_active = 1 WHERE scenario_name = '{scenario_name}'")
        self.conn.commit()
        self.active_scenario_name = scenario_name
        self.active_scenario_id = self.getid_current_scenario()
    def remove_all_scenarios(self):
        """Remove all scenarios from the 'scenarios' table."""
        try:
            # Check if there are any scenarios using COUNT
            self.cur.execute("""
                DROP TABLE IF EXISTS T_Scenarios;
            """)

        except psycopg2.Error as e:
            logging.error(f"Error while checking or removing scenarios: {e}")

            raise
    def close_connection(self):
        """Closes the database connection."""
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()
        logging.info("Database connection closed.")