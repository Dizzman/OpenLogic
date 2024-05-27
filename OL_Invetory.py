
import logging
from Mapper import  Mapper
from openpyxl import load_workbook
from OL_BaseObject import OLBaseObject
from Obj_Types import OBJECT_TYPE

class InventoryClass(OLBaseObject):
        def __init__(self,BaseModel,ObjName):
            super().__init__(BaseModel, ObjName)
            logging.debug("Create Map2Column Inventory")
            self.m_nameTable = self.BaseModel.getInventoryesNameTable()
            m_ol_list_column = self.BaseModel.getColumnsofTable(self.m_nameTable)
            self.m_mapper = Mapper(m_ol_list_column)
            self.m_mapper.openxlsmap('mapInventoryColumnNames.xlsx')
            self.ObjType = OBJECT_TYPE.Inventory
        def Add_MTP_Rows(self,xlsxfile):
            super().AddObject_Rows(self.ObjName,xlsxfile)

