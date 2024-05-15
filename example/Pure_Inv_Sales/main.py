from  OL_BaseObject import ORBaseObject
from enum import Enum
from  OL_BaseTables import OLBaseTables
from  Obj_Types import OBJECT_TYPE
from Log_setting import InitLoger

InitLoger()

Model = OLBaseTables(namedb="Test1.db", namemodel="TestModel")
#Model.CreateEmptyMaterialsTable()
#Model.CreateEmptyLocationsTable()
Model.CreateEmptyPurchaseTable(name="Purchase1")   # Create Empty Table for Purchase
Model.CreateEmptyInventoryTable(name="Inventory1") # Create Empty Table for Inventory
Model.CreateEmptySalesTable(name="Sales1")         # Create Empty Table for Sales
Model.CreateEmptyLink(nameFrom="Purchase1",nameTo="Inventory1",typeLink=OBJECT_TYPE.MixPurch2Inv)    # Create Empty Link SortPurch2Inv
Model.CreateEmptyLink(nameFrom="Inventory1",nameTo="Sales1",typeLink=OBJECT_TYPE.MixInv2Sale)    # Create Empty Link SortPurch2Inv
