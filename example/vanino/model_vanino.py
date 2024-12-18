import logging
from logger.logger import setup_logging
from config.db_config import DatabaseConfig
setup_logging()
from load_data_to_source_table import LoaderSourceDataToBD

A=LoaderSourceDataToBD('source_data/Work_simple.xlsx',DatabaseConfig)

logging.info("fff")