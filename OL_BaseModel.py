import sqlite3

from Obj_Types import OBJECT_TYPE
import enum
import logging
MAX_REAL_STR = '10000000'
from OL_Purchase import PurchasesClass
from OL_Invetory import InventoryClass
from OL_Sales import SalesClass
from OL_P2IMix import P2IMixClass
from OL_I2SMix import I2SMixClass



class OLBaseModelClass():

    def __init__(self, namedb,namemodel):
        self.m_nameTable = ''
        self.name = namedb # name of DB file
        self.model_name = namemodel
        self.connection = sqlite3.connect(self.name)
        self.cursor = self.connection.cursor()

        tales = self._show_all_tables()
        logging.info(f"Exist tables {tales}")

        self._drop_tables(tales)
        logging.info(f"Droped all tables {tales}")
        self.connection.commit()
        #connection.close()
        self.Purchases = {}
        self.Inventories = {}
        self.Sales = {}
        self.LinkP2IMix = {}
        self.LinkI2SMix = {}
        self.prefixDBTable = "T_OSL_"
        self.m_session_id = 1
        self.NameToType = {}

    def _show_all_tables(self):
        res = []
        self.cursor.execute("select * from sqlite_master where type='table'")
        fetch = self.cursor.fetchall()
        for i in fetch:
            res.append(i[1])
        return res
    def _drop_tables(self,lsttables):
        #elf.cursor.execute("select 'drop table ' || name || ';' from sqlite_master where type = 'table';")
        #command_ = self.cursor.fetchall()
        if len(lsttables)>0:
            logging.debug(f"Trying drop all tables {str(lsttables)}")
            for c in lsttables:
                self.cursor.execute(f'DROP TABLE {c}')
                logging.debug(f"Drop complited -  {c}")

    def getPurchasesNameTable(self):
        return f'{self.prefixDBTable}Purchases'
    def getInventoryesNameTable(self):
        return f'{self.prefixDBTable}Inventories'
    def getSalesNameTable(self):
        return f'{self.prefixDBTable}Sales'
    def getLinkP2IMixNameTable(self):
        return f'{self.prefixDBTable}LinkP2IMix'
    def getLinkI2SMixNameTable(self):
        return f'{self.prefixDBTable}LinkI2SMix'
    def CreatePurchasesTable(self):
        self.cursor.execute(f'''
        CREATE TABLE  IF NOT EXISTS {self.getPurchasesNameTable()} 
        (
        	_sessionID INTEGER  DEFAULT{self.m_session_id},
			ObjectName TEXT NOT NULL,
			TimePeriod TEXT NOT NULL,
			Location TEXT NOT NULL,
			ItemDescription TEXT NOT NULL,
			CostUnit REAL DEFAULT 0,
			MinUnits REAL DEFAULT 0,
			MaxUnits REAL DEFAULT {MAX_REAL_STR},
			CostPerUnitFactor REAL DEFAULT 0,
			CostPerUnitAdd REAL DEFAULT 0,
			MaxUnitsFactor REAL DEFAULT 0,
			MaxUnitsAdd REAL DEFAULT {MAX_REAL_STR},
			VarType TEXT NOT NULL,
			Row_ID INTEGER PRIMARY KEY
        )
        ''')

        logging.debug("Created  Purchases table ")



#    def AddInventoryObject(self, Objname):
#        nameTable = self.getInventoryesNameTable()
    def CreateInventoryesTable(self):

        self.cursor.execute(f'''               
                CREATE TABLE IF NOT EXISTS {self.getInventoryesNameTable()}
                (
                    _sessionID INTEGER  DEFAULT{self.m_session_id},
                    ObjectName TEXT NOT NULL,
                    TimePeriod TEXT NOT NULL,
                    Location TEXT NOT NULL,
                    Material TEXT NOT NULL,
                    Attribute1 TEXT,
                    Attribute2 TEXT,
                    Attribute3 TEXT,
                    Attribute4 TEXT,
                    MinBeginUnitsFirstPeriod REAL DEFAULT 0,
                    MaxBeginUnitsFirstPeriod REAL DEFAULT 0,
                    MinEndUnitsFirstPeriod REAL DEFAULT 0,
                    MaxEndUnitsFirstPeriod REAL DEFAULT {MAX_REAL_STR},
                    Row_ID INTEGER PRIMARY KEY                    
                )''')
        logging.debug("Created Inventyes table ")



    def CreateSalesTable(self):
        self.cursor.execute(f'''               
        CREATE TABLE IF NOT EXISTS {self.getSalesNameTable()}
        (
            _sessionID INTEGER  DEFAULT{self.m_session_id},
            ObjectName TEXT NOT NULL,
            TimePeriod TEXT NOT NULL,
            Location TEXT NOT NULL,
            ItemDescription TEXT NOT NULL,
            Attribute1 TEXT,
            Attribute2 TEXT,
            Attribute3 TEXT,
            Attribute4 TEXT,
            PriceUnit REAL DEFAULT 0,
            MinUnits  REAL DEFAULT 0,
            MaxUnits  REAL DEFAULT {MAX_REAL_STR},
            VarType TEXT NOT NULL,
            Row_ID INTEGER PRIMARY KEY
        )''')
        logging.debug("Created Sales Table ")

    #def AddSalesObject(self, Objname):
    #    nameTable = self.getSalesNameTable()
    def CreateLinkP2IMixTable(self):

        self.cursor.execute(f'''               
                CREATE TABLE IF NOT EXISTS {self.getLinkP2IMixNameTable()}
                (
                    _sessionID INTEGER  DEFAULT{self.m_session_id},                   
                    ObjectName TEXT NOT NULL,
                    FromObjectName TEXT NOT NULL,
                    ToObjectName TEXT NOT NULL,
                    TimePeriod TEXT NOT NULL,
                    FromLocation TEXT NOT NULL,
                    ToLocation TEXT NOT NULL,
                    ItemDescription TEXT NOT NULL,
                    Material TEXT NOT NULL,
                    Yield REAL DEFAULT 1.0,
                    Attribute1 TEXT NOT NULL,
                    Attribute2 TEXT NOT NULL,
                    Attribute3 TEXT NOT NULL,
                    Attribute4 TEXT NOT NULL,
                    MinUnits   REAL DEFAULT 0.0,
                    MaxUnits   REAL DEFAULT {MAX_REAL_STR},
                    Row_ID INTEGER PRIMARY KEY
                )''')


        logging.debug("Created Links P2IMix Table ")
    def CreateLinkI2SMixTable(self):

        self.cursor.execute(f'''               
                CREATE TABLE IF NOT EXISTS {self.getLinkI2SMixNameTable()}
                (
                    _sessionID INTEGER  DEFAULT{self.m_session_id},   
                    ObjectName TEXT NOT NULL,
                    FromObjectName TEXT NOT NULL,
                    ToObjectName TEXT NOT NULL,
                    TimePeriod TEXT NOT NULL,
                    FromLocation TEXT NOT NULL,
                    ToLocation TEXT NOT NULL,
                    ItemDescription TEXT NOT NULL,
                    Material TEXT NOT NULL,
                    Distribution REAL DEFAULT 1.0,
                    Attribute1 TEXT NOT NULL,
                    Attribute2 TEXT NOT NULL,
                    Attribute3 TEXT NOT NULL,
                    Attribute4 TEXT NOT NULL,
                    MinUnits   REAL DEFAULT 0.0,
                    MaxUnits   REAL DEFAULT {MAX_REAL_STR},
                    Row_ID INTEGER PRIMARY KEY
                )''')


        logging.debug("Created Links P2IMix Table ")

    def getColumnsofTable(self,nameTable):
        self.cursor.execute(f"PRAGMA table_info({nameTable})")
        fetch = self.cursor.fetchall()
        return [i[1] for i in fetch ]

    def Add_Inventory_ObjectByMTPRows(self, ObjName, xlsxfile):
        self.Inventories[ObjName]=InventoryClass(self,ObjName)
        self.Inventories[ObjName].AddObject_Rows( xlsxfile)
    def Add_Purchase_ObjectByMTPRows(self, ObjName, xlsxfile):
        self.Purchases[ObjName]=PurchasesClass(self,ObjName)
        self.Purchases[ObjName].AddObject_Rows(xlsxfile)
    def Add_Sales_ObjectByMTPRows(self, ObjName, xlsxfile):
        self.Sales[ObjName]=SalesClass(self,ObjName)
        self.Sales[ObjName].AddObject_Rows(xlsxfile)
    def Add_P2IMix_ObjectByMTPRows(self, ObjName, FromObjectName, ToObjectName, xlsxfile):
        self.LinkP2IMix[ObjName]=P2IMixClass(self,ObjName,FromObjectName, ToObjectName)
        self.LinkP2IMix[ObjName].AddObject_Rows(xlsxfile)
    def Add_I2SMix_ObjectByMTPRows(self, ObjName,FromObjectName, ToObjectName, xlsxfile):
        self.LinkI2SMix[ObjName]=I2SMixClass(self,ObjName,FromObjectName, ToObjectName)
        self.LinkI2SMix[ObjName].AddObject_Rows(xlsxfile)

    def Build_BackPropogationLP(self):
    # Start from Sale

        pass