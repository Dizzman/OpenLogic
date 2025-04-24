import sys
import os

import logging
import psycopg2
from  config.db_config import DatabaseConfig
import  re

class OLEngineCore:
    def __init__(self,config_db:DatabaseConfig):
        self.config_db = config_db
        self.active_scenario_name = 'NONE'
        self.project_name = 'NONE'
        self.active_scenario_id = -1
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
            self.logger = logging.getLogger(self.__class__.__name__)
            self.logger.info(
                f"set DB name = {self.get_currdb()} ")
            self.logger.info(self.cur.fetchone())
            self.list_databases()
        except psycopg2.Error as e:
            self.logger.error(f"Error connecting to the database: {e}")
            raise

    def get_currdb(self):
        if self.conn is not None:
            curdb = self.conn.get_dsn_parameters()['dbname']
        return curdb
    def connect_to_database(self,project_name):
        try:
            if  self.conn is not None:
                curdb=self.conn.get_dsn_parameters()['dbname']
                self.logger.info(f"Current connect: {curdb}")
                self.logger.info(f"Close opened connect")
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
            self.logger.info(f"Connected to : {project_name}")


        except Exception as e:
            self.logger.error(f"Error to connect {project_name}: {e}")
            return None
    def list_databases(self):
        """List all databases in the PostgreSQL instance."""
        try:
            self.cur.execute("SELECT datname FROM pg_database WHERE datistemplate = false;")
            databases = self.cur.fetchall()
            self.logger.info(f"Databases in the system: {databases}")
            return databases
        except psycopg2.Error as e:
            self.logger.error(f"Error while listing databases: {e}")
            return []

    def create_projectDB(self, project_name):
        """Creates a new database for the project."""
        try:

            self.cur.execute(f"CREATE DATABASE {project_name};")
            self.conn.commit()
            self.logger.info(f"Database '{project_name}' successfully created.")

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
            self.logger.info(f"Connected to the newly created database '{project_name}'.")


            self.conn.commit()
            self.logger.info(f"Table 'projects' created in database '{project_name}'.")

        except psycopg2.Error as e:
            self.logger.error(f"Error while creating the project database: {e}")

    def remove_projectDB(self, project_name):
        """Removes the project database."""
        try:

            self.cur.execute(f"DROP DATABASE IF EXISTS {project_name};")
            self.conn.commit()
            self.logger.info(f"Database '{project_name}' successfully removed.")
        except psycopg2.Error as e:
            self.logger.error(f"Error while removing the project database: {e}")

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
            self.logger.info(f"Scenario with ID {scenario_name} successfully created.")
        except psycopg2.Error as e:
            self.logger.error(f"Error while creating scenario: {e}")

    def getid_current_scenario(self):
        self.cur.execute(f"select id from T_Scenarios WHERE is_active = 1")
        ids = self.cur.fetchall()
        return [id[0] for id in ids][0]

    def setcurrent_scenario(self, project_name, scenario_name: str):
        self.logger.info(f"setcurrent_scenario project_name={project_name} scenario_name= {scenario_name}")
        try:

            # 1. Check if scenario exists
            self.cur.execute("""
                       SELECT _ScenarioId FROM T_Scenarios 
                       WHERE project_name = %s AND scenario_name = %s
                       FOR UPDATE
                   """, (project_name, scenario_name))

            scenario_data = self.cur.fetchone()

            # 2. Deactivate all scenarios for this project
            self.cur.execute("""
                       UPDATE T_Scenarios 
                       SET is_active = FALSE 
                                      """)

            # 3. Activate current scenario (update or insert)
            if scenario_data:
                # Scenario exists - activate it
                scenario_id = scenario_data[0]
                self.cur.execute("""
                           UPDATE T_Scenarios 
                           SET is_active = TRUE 
                           WHERE _ScenarioId= %s
                           RETURNING _ScenarioId
                       """, (scenario_id,))
            else:
                # Scenario doesn't exist - insert new active one
                self.cur.execute("""
                           INSERT INTO T_Scenarios 
                           (scenario_name, project_name, is_active, created_at) 
                           VALUES (%s, %s, TRUE, NOW())
                           RETURNING _ScenarioId
                       """, (scenario_name, project_name))

            # Get the scenario ID
            result = self.cur.fetchone()
            scenario_id = result[0] if result else None

            # Commit transaction
            self.conn.commit()

            # Update local state

            self.active_scenario_name = scenario_name
            self.project_name = project_name
            self.active_scenario_id = scenario_id




        except Exception as e:
            # Rollback on error
            self.conn.rollback()
            print(f"Error setting active scenario: {str(e)}")
            return False

    def remove_all_scenarios(self):
        """Remove all scenarios from the 'scenarios' table."""
        try:
            # Check if there are any scenarios using COUNT
            self.cur.execute("""
                DROP TABLE IF EXISTS T_Scenarios;
            """)

        except psycopg2.Error as e:
            self.logger.error(f"Error while checking or removing scenarios: {e}")

            raise
    def close_connection(self):
        """Closes the database connection."""
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()
        self.logger.info("Database connection closed.")

    def extract_table_name(self, sql_query):
        """
        Извлекает имя таблицы из SQL-запроса CREATE TABLE.
        """
        # Регулярное выражение для поиска имени таблицы
        match = re.search(r"CREATE TABLE (?:IF NOT EXISTS )?(\w+)", sql_query, re.IGNORECASE)
        if match:
            return match.group(1)  # Возвращаем имя таблицы
        return None

    def extract_procedure_or_function_name(self, sql_query):
        """
        Извлекает имя процедуры или функции из SQL-запроса.
        """
        # Регулярное выражение для поиска имени процедуры или функции
        match = re.search(
            r"CREATE OR REPLACE (?:PROCEDURE|FUNCTION)\s+(\w+)",
            sql_query,
            re.IGNORECASE
        )
        if match:
            return match.group(1)  # Возвращаем имя процедуры или функции
        return None
    def extract_table_name(self, sql_query):
        """
        Извлекает имя таблицы из SQL-запроса CREATE TABLE.
        """
        # Регулярное выражение для поиска имени таблицы
        match = re.search(r"CREATE TABLE (?:IF NOT EXISTS )?(\w+)", sql_query, re.IGNORECASE)
        if match:
            return match.group(1)  # Возвращаем имя таблицы
        return None
    def execute_sql_file(self, file_path):
        try:
            with open(file_path, 'r',encoding="utf-8") as file:
                sql_script = file.read()
                self.cur.execute(sql_script)
                #self.ol_engine.cur.execute("SELECT public.eosms_run_all_sp(%s);", (self.ol_engine.active_scenario_id,))
                self.conn.commit()   # Commit changes
                #self.logger.info(f"SQL procedure {self.extract_procedure_or_function_name(sql_script)} in {file_path} executed")
                self.logger.info(f"SQL table {self.extract_table_name(sql_script)} in {file_path} executed")
        except Exception as e:

            self.logger.info(f"Error executed SQL файла: {e}")
            self.conn.rollback()  # Rollback changes in case of error
            raise ValueError(f"Error executed SQL файла: {e}")
    def add_sql_procedure_from_file(self, file_path):
        try:
            with open(file_path, 'r',encoding="utf-8") as file:
                sql_script = file.read()

                self.cur.execute(sql_script)
                self.conn.commit()   # Commit changes
                self.logger.info(
                    f"SQL procedure {self.extract_procedure_or_function_name(sql_script)} in {file_path} try added ")
        except Exception as e:
            self.logger.info(f"Error: {self.extract_procedure_or_function_name(sql_script)} executed SQL файла: {e} ")
            self.rollback()  # Rollback changes in case of error
