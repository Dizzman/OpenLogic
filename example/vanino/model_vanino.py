import logging
from ol_engine.core.ol_engine import OLEngineCore
from logger.logger import setup_logging
from config.db_config import DatabaseConfig
setup_logging()
from load_data_to_source_table import LoaderSourceDataToBD

Scenario = 'test1'
Comment= 'comment'
ProjectName = 'vaninodb'

ol=OLEngineCore(DatabaseConfig)
#ol.remove_projectDB(ProjectName)
#ol.create_projectDB(ProjectName)
ol.connect_to_database(ProjectName)
#ol.remove_all_scenarios()
#ol.create_scenario(Scenario,Comment)
ol.setcurrent_scenario(ProjectName,Scenario)


A=LoaderSourceDataToBD(ol,'./source_data/Work_simple.xlsx','./source_data/Work_Optimizer_Dev_simple_good.xlsm')
A.deleteallsta_tables()
#A.savedatafile_to_database()
#A.saveconffile_to_database()
A.delete_all_procedures()
A.load_configure_from_xls_to_db()
A.load_vessels_from_xls_to_db()

A.createt_T_EOtemp_ActiveVessel()
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EOtemp_ActiveVessel_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EOSMS_RunAllSP_sp.sql')


logging.info("fff")