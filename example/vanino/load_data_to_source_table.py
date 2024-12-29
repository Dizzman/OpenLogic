import logging
import sys
import openpyxl
import psycopg2
from config.db_config import DatabaseConfig
from ol_engine.core.ol_engine import OLEngineCore
class LoaderSourceDataToBD():
    def __init__ (self, ol_engeen:OLEngineCore, datafile:str,conffile:str):
        """
        Initialize LoaderSourceData
        :param datafile:
        :param db_cnf:
        """
        self.datafile = datafile
        self.conffile = conffile
        self.ol_engine = ol_engeen
        self.workbook = None
        self.logger = logging.getLogger(self.__class__.__name__)
        self.logger.info(f"set datafile= {self.datafile}, conffile= {self.conffile} DB name = {self.ol_engine.get_currdb()} Scenario_id= { self.ol_engine.active_scenario_id}")

       # self.ol_engine.cur.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';")
        #tables = self.ol_engine.cur.fetchall()

        # Вывод таблиц
        #for table in tables:
        #    print(table[0])
    def opendata_xlsx_file(self):
        """
        Open the Excel file and load the workbook.
        """
        try:
            self.workbook_datafile = openpyxl.load_workbook(self.datafile)
        except FileNotFoundError:
            self.logger.fatal(f"The file at {self.datafile} was not found. ")
            raise FileNotFoundError(f"The file at {self.datafile} was not found.")
        except Exception as e:
            self.logger.fatal(f"An error occurred while opening the file: {e} ")
            raise Exception(f"An error occurred while opening the file: {e}")
    def openconfig_xlsx_file(self):
        """
        Open the Excel file and load the workbook.
        """
        try:
            self.workbook_conffile = openpyxl.load_workbook(self.conffile)
        except FileNotFoundError:
            self.logger.fatal(f"The file at {self.conffile} was not found. ")
            raise FileNotFoundError(f"The file at {self.conffile} was not found.")
        except Exception as e:
            self.logger.fatal(f"An error occurred while opening the file: {e} ")
            raise Exception(f"An error occurred while opening the file: {e}")

    def deleteallsta_tables(self):
        tables = ['Configuration']
        for i in tables:
            self.ol_engine.cur.execute(f"DROP TABLE IF EXISTS {i}")
        self.ol_engine.conn.commit()
    def saveconffile_to_database(self):
        """
        Save data from into the database.

        :param sheet_name: Name of the sheet_config to save data from
        :param table_name: Name of the database table to insert data into
        """
        self.openconfig_xlsx_file()
        self.opendata_xlsx_file()
        sheet_config = self.workbook_conffile["Config"]
        sheet_vessels = self.workbook_datafile["Vessels"]
        sheet_cargo = self.workbook_datafile["Cargo"]
        config_data = {
             'NumberOfPiles': sheet_config.cell(row=2, column=3).value,
             'NumberOfVessels': sheet_config.cell(row=3, column=3).value,
             'NumberOfDiscreteDays': sheet_config.cell(row=4, column=3).value,
             'NumberOfQCs': sheet_config.cell(row=5, column=3).value,
             'NumberOfDays': sheet_config.cell(row=6, column=3).value,
             'ConfirmedDays': sheet_cargo.cell(row=7, column=1).value,
             'DVZHDDays': sheet_cargo.cell(row=9, column=1).value,
             'FarawayDays': sheet_cargo.cell(row=11, column=1).value,
             'PlannedDays': sheet_cargo.cell(row=13, column=1).value,
             'NumberOfWeekPeriods': sheet_config.cell(row=7, column=3).value,
             'NumberOf2WeekPeriods': sheet_config.cell(row=8, column=3).value,
             'Maxshiftdefault': sheet_config.cell(row=10, column=3).value # Запись можно брать из Vessels
        }
        self.logger.info("Data extracted: %s", config_data)
        # Create table if it does not exist
        self.ol_engine.cur.execute("""
                CREATE TABLE IF NOT EXISTS Configuration (
                    _ScenarioID INT,
                    NumberOfPiles INT,
                    NumberOfVessels INT,
                    NumberOfDiscreteDays INT,
                    NumberOfQCs INT,
                    NumberOfDays INT,
                    ConfirmedDays INT,
                    DVZHDDays INT,
                    FarawayDays INT,
                    PlannedDays INT,
                    NumberOfWeekPeriods INT,
                    NumberOf2WeekPeriods INT,
                    Maxshiftdefault INT);
                """)
        self.logger.info("Configuration table checked/created.")

        # Check for records with _ScenarioID = 1
        self.ol_engine.cur.execute("""
                SELECT COUNT(*) FROM Configuration 
                WHERE _ScenarioID = %s
                """, (self.ol_engine.active_scenario_id ,))
        count = self.ol_engine.cur.fetchone()[0]  # Get the count of records

        if count > 0:
            self.logger.info("Found %d records with _ScenarioID = %d. Proceeding to delete.", count,
                             self.ol_engine.active_scenario_id)
            # Delete records where _ScenarioID = 1
            self.ol_engine.cur.execute("""
                    DELETE FROM Configuration 
                    WHERE _ScenarioID = %s
                    """, (self.ol_engine.active_scenario_id,))
            self.logger.info(f"Records with _ScenarioID = %d deleted.", self.ol_engine.active_scenario_id)
        else:
            self.logger.info("No records found with _ScenarioID = %d. Deletion not required.",
                             self.ol_engine.active_scenario_id)

        # Insert data with explicit enumeration
        self.ol_engine.cur.execute("""
                INSERT INTO Configuration (_ScenarioID,NumberOfPiles, NumberOfVessels, NumberOfDiscreteDays, NumberOfQCs, 
                                           NumberOfDays, ConfirmedDays, DVZHDDays, FarawayDays, PlannedDays,NumberOfWeekPeriods,NumberOf2WeekPeriods,Maxshiftdefault) 
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
            self.ol_engine.active_scenario_id,
            config_data['NumberOfPiles'],
            config_data['NumberOfVessels'],
            config_data['NumberOfDiscreteDays'],
            config_data['NumberOfQCs'],
            config_data['NumberOfDays'],
            config_data['ConfirmedDays'],
            config_data['DVZHDDays'],
            config_data['FarawayDays'],
            config_data['PlannedDays'],
            config_data['NumberOfWeekPeriods'],
            config_data['NumberOf2WeekPeriods'],
            config_data['Maxshiftdefault']

        ))

        self.logger.info("Data successfully inserted into the Configuration table.")
        self.ol_engine.conn.commit()
        pass
    # def saveconffile_to_database(self):
    #     """
    #     Save data from into the database.
    #
    #     :param sheet_name: Name of the sheet to save data from
    #     :param table_name: Name of the database table to insert data into
    #     """
    #     self.openconfig_xlsx_file()
    #     sheet = self.workbook_conffile["Config"]
    #     pass
