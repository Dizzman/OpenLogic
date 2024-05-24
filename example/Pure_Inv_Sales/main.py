import logging

from  OL_BaseObject import OLBaseObject
from enum import Enum
from  OL_BaseModel import OLBaseModelClass

from  Obj_Types import OBJECT_TYPE
from Log_setting import InitLoger

import os
InitLoger()
bpath = os.getcwd()
Model = OLBaseModelClass(namedb="Test1.db", namemodel="TestModel")
#Model.CreateEmptyMaterialsTable()
#Model.CreateEmptyLocationsTable()
Model.CreatePurchasesTable()   # Create  Table for Purchases
Model.CreateInventoryesTable() # Create  Table for Inventories
Model.CreateSalesTable()       # Create  Table for Sales
Model.CreateLinkP2IMixTable()       # Create  Table for P2I Links
Model.CreateLinkI2SMixTable()       # Create  Table for I2S Links

Model.Add_Purchase_ObjectByMTPRows(ObjName="Purchase1", xlsxfile="Purchase1 - PurchaseActivityMTP.xlsx")
Model.Add_Inventory_ObjectByMTPRows(ObjName="Inventory1", xlsxfile="Inventory1 - InventoryActivityMTP.xlsx")
Model.Add_Sales_ObjectByMTPRows(ObjName="Sales1", xlsxfile="Sales1 - SalesActivityMTP.xlsx")
Model.Add_P2IMix_ObjectByMTPRows(ObjName="LinkP2IMix1",xlsxfile="Mix (Purch To Inv)1 - MixYieldMTP.xlsx")
Model.Add_I2SMix_ObjectByMTPRows(ObjName="LinkP2IMix1",xlsxfile="Mix (Inv to Sales)1 - MixDistributionMTP.xlsx")

#Model.