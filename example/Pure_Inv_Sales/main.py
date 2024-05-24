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
Model.CreatePurchasesTable()   # Create  Table for Purchase
Model.CreateInventoryesTable() # Create  Table for Inventoryes
Model.CreateSalesTable()       # Create  Table for Sales
Model.CreateLinksTable()       # Create  Table for Links
#(nameFrom="Purchase1",namelink="LinkMix_Purchase1_To_Inventory1",nameTo="Inventory1",typeLink=OBJECT_TYPE.MixPurch2Inv)    # Create Empty Link SortPurch2Inv
#Model.CreateEmptyLink(nameFrom="Inventory1",namelink="LinkMix_Inventory1_To_Sales1",nameTo="Sales1",typeLink=OBJECT_TYPE.MixInv2Sale)        # Create Empty Link SortPurch2Inv

Model.AddPurchaseObject_ByMTP_Rows(ObjName="Purchase1",xlsxfile="Purchase1 - PurchaseActivityMTP.xlsx")
Model.AddInventoryObject_ByMTP_Rows(ObjName="Inventory1",xlsxfile="Inventory1 - InventoryActivityMTP.xlsx")
Model.AddSalesObject_ByMTP_Rows(ObjName="Sales1",xlsxfile="Sales1 - SalesActivityMTP.xlsx")
#Model.AddInventoryObject(name="Inventory1")
#Model.