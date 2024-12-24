import logging
from ol_engine.core.ol_engine import OLEngineCore
from logger.logger import setup_logging
from config.db_config import DatabaseConfig
setup_logging()
from load_data_to_source_table import LoaderSourceDataToBD

Scenario = 'test1'
Comment= 'comment'
ProjectName = 'VaninoDB'

ol=OLEngineCore(DatabaseConfig)
#ol.remove_projectDB(ProjectName)
#ol.create_projectDB(ProjectName)
ol.remove_all_scenarios()
ol.create_scenario(Scenario,Comment)


A=LoaderSourceDataToBD('source_data/Work_simple.xlsx')
A.save_to_database()

logging.info("fff")