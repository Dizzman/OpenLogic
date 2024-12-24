import logging
import sys
import openpyxl
import psycopg2
from config.db_config import DatabaseConfig
class LoaderSourceDataToBD():
    def __init__ (self,filename,db_cnf:DatabaseConfig):
        """
        Initialize LoaderSourceData
        :param filename:
        :param db_cnf:
        """
        self.filename = filename
        self.db_cnf = db_cnf
        self.workbook = None
        self.logger = logging.getLogger(self.__class__.__name__)
        self.logger.info(f"set filename {self.filename} and dest DB is db_cnf {self.db_cnf.dbname}")
        self.logger.info(f"try to connect to {DatabaseConfig.dbname}")
        try:
            self.conn = psycopg2.connect(
                dbname=DatabaseConfig.dbname,
                user=DatabaseConfig.user,
                password=DatabaseConfig.password,
                host=DatabaseConfig.host,
                port=DatabaseConfig.port
            )
        except:
            self.logger.fatal(f"Error to connect DB {DatabaseConfig.dbname}, Exit() ")
            sys.exit(-1)

        self.logger.info(f"Success connect to DB")

    def open_xlsx_file(self):
        """
        Open the Excel file and load the workbook.
        """
        try:
            self.workbook = openpyxl.load_workbook(self.filename)
        except FileNotFoundError:
            self.logger.fatal(f"The file at {self.filename} was not found. ")
            raise FileNotFoundError(f"The file at {self.filename} was not found.")
        except Exception as e:
            self.logger.fatal(f"An error occurred while opening the file: {e} ")
            raise Exception(f"An error occurred while opening the file: {e}")

    def get_sheet(self, sheet_name):
        """
        Retrieve a worksheet by its name.

        :param sheet_name: Name of the worksheet to retrieve
        :return: Worksheet object
        """
        if self.workbook is None:
            raise Exception("Workbook is not loaded. Please open the file first.")

        try:
            return self.workbook[sheet_name]
        except KeyError:
            raise KeyError(f"Sheet '{sheet_name}' does not exist in the workbook.")

    def save_to_database(self):
        """
        Save data from into the database.

        :param sheet_name: Name of the sheet to save data from
        :param table_name: Name of the database table to insert data into
        """
        self.open_xlsx_file()
        sheet = self.get_sheet("Vessels")

