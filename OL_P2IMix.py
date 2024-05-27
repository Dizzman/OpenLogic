
import logging
from Mapper import  Mapper
from openpyxl import load_workbook
from OL_BaseObject import OLBaseObject
from Obj_Types import OBJECT_TYPE

class P2IMixClass(OLBaseObject):
        def __init__(self,BaseModel,ObjName,FromObjectName,ToObjectName):
            super().__init__(BaseModel, ObjName)
            logging.debug("Create Map2Column P2IMix")
            self.m_nameTable = self.BaseModel.getLinkP2IMixNameTable()
            m_ol_list_column = self.BaseModel.getColumnsofTable(self.m_nameTable)
            self.m_mapper = Mapper(m_ol_list_column)
            self.m_mapper.openxlsmap('mapP2IColumnNames.xlsx')
            self.FromObjectName = FromObjectName
            self.ToObjectName = ToObjectName
            self.ObjType = OBJECT_TYPE.MixPurch2Inv
        def Add_MTP_Rows(self,xlsxfile):
            super().AddObject_Rows( self.nameObj,xlsxfile)

