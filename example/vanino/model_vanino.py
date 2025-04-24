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


A=LoaderSourceDataToBD(ol,'./source_data/Work_simple.xlsx','./source_data/Work_Optimizer_Dev_simple_good.xlsm')
A.deleteallsta_tables()
#A.savedatafile_to_database()
#A.saveconffile_to_database()
A.delete_all_procedures()
#A.create_Configuration()

A.execute_sql_file("./sql_scripts/T_tables/T_Scenarios.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_Configuration.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_EOtemp_ActiveVessel.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_Vessels.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_Volumes.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_Piles.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_PileQuality.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_QltCharacteristics.sql")
A.execute_sql_file("./sql_scripts/T_tables/T_QualityRestrictions.sql")

ol.setcurrent_scenario(ProjectName,Scenario)
A.load_configure_from_xls_to_db()

A.load_vessels_from_xls_to_db()
A.load_cargo_data()
A.load_Q()
A.load_Vol()
A.load_PilesQ()

A.create_EO_Tables()


A.add_sql_procedure_from_file(file_path='./sql_scripts/GetPartFromToCode.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EOtemp_ActiveVessel_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_E_TimePeriodDefinitions_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_E_LocationDefinitions_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_A_AttributeDefinitions_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_C_ConstraintSetDefenitions_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_E_LocationDefinitionsMTP_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_P_PurchaseActivity_Incoming_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_PtI_MixYield_Incoming_to_Piles_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_I_InventoryActivity_Piles_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_PtI_MixYield_Incoming_to_Ships_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_S_SalesActivity_Sales_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_ItS_MixDistribution_Ships_to_Sales_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_I_InventoryActivity_Ships_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_ItI_TransferActivity_Piles_to_Ships_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_ItI_FromShipmentDescription_Piles_to_Ships_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_ItI_ToShipmentDescription_Piles_to_Ships_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_I_RatioDefinitions_Ships_sp.sql')
A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EO_P_PurchaseActivityMTP_Incoming_sp.sql')

#A.add_sql_procedure_from_file(file_path='./sql_scripts/SChaMa_EOSMS_RunAllSP_sp.sql')

print(A.getall_proc())
A.call_sql_procedure_for_active_scenario('public.SChaMa_EOtemp_ActiveVessel_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_E_TimePeriodDefinitions_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_E_LocationDefinitions_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_A_AttributeDefinitions_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_C_ConstraintSetDefinitions_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_E_LocationDefinitionsMTP_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_P_PurchaseActivity_Incoming_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_PtI_MixYield_Incoming_to_Piles_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_I_InventoryActivity_Piles_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_PtI_MixYield_Incoming_to_Ships_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_S_SalesActivity_Sales_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_ItS_MixDistribution_Ships_to_Sales_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_I_InventoryActivity_Ships_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_ItI_TransferActivity_Piles_to_Ships_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_ItI_FromShipmentDescription_Piles_to_Ships_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_ItI_ToShipmentDescription_Piles_to_Ships_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_I_RatioDefinitions_Ships_sp')
A.call_sql_procedure_for_active_scenario('public.SChaMa_EO_P_PurchaseActivityMTP_Incoming_sp')


logging.info("fff")