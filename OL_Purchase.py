
import logging
from Mapper import  Mapper
from openpyxl import load_workbook
from OL_BaseObject import OLBaseObject
from Obj_Types import OBJECT_TYPE

class PurchasesClass(OLBaseObject):
        def __init__(self,BaseModel,ObjName):
            super().__init__(BaseModel, ObjName)
            logging.debug("Create Map2Column Purchases")
            self.m_nameTable = self.BaseModel.getPurchasesNameTable()
            m_ol_list_column = self.BaseModel.getColumnsofTable(self.m_nameTable)
            self.m_mapper = Mapper(m_ol_list_column)
            self.m_mapper.openxlsmap('mapPurchaseColumnNames.xlsx')
            self.ObjType = OBJECT_TYPE.Purchase

        def Add_MTP_Rows(self,xlsxfile):
            super().AddObject_Rows( self.nameObj,xlsxfile)

