import logging
import sys
import os


project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../'))
sys.path.append(project_root)

from ol_engine.core.ol_engine import OLEngineCore # type: ignore
from logger.logger import setup_logging # type: ignore
from config.db_config import DatabaseConfig # type: ignore
setup_logging()
from vanino_createtables_and_procudures import LoaderSourceDataToBD

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
#A.create_Configuration()
A.execute_sql_file("./sql_scripts/T_tables/T_Configuration.sql")

A.load_configure_from_xls_to_db()
A.execute_sql_file("./sql_scripts/T_tables/T_EOtemp_ActiveVessel.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_Vessels.sql")
A.load_vessels_from_xls_to_db()

A.create_EO_Tables()



A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EOtemp_ActiveVessel_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_E_TimePeriodDefinitions_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_E_LocationDefinitions_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_C_ConstraintSetDefenitions.sql')
#A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EOSMS_RunAllSP_sp.sql')

print(A.getall_proc())
A.call_sql_procedure_for_active_scenario('public.EOtemp_ActiveVessel_sp')
A.call_sql_procedure_for_active_scenario('public.EO_E_LocationDefinitions_sp')
A.call_sql_procedure_for_active_scenario('public.EO_E_TimePeriodDefinitions_sp')



logging.info("fff")