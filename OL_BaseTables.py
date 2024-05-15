import sqlite3
from Obj_Types import OBJECT_TYPE
import enum
import logging
MAX_REAL_STR = '10000000'


#class OBJECT_TYPE(enum.Enum):
   # Purchase=1
    # Inventory=2
    # Sales=3
    # SortInv2Inv=4
    # SortInv2Sale=5
    # SortPurch2Inv=6
    # MixInv2Inv=7
    # MixInv2Sale=8
    # MixPurch2Inv=9



class OLBaseTables():

    def __init__(self, namedb,namemodel):

        self.name = namedb # name of DB file
        self.model_name = namemodel
        self.connection = sqlite3.connect(self.name)
        self.cursor = self.connection.cursor()
        tales = self._show_all_tables()
        logging.info(f"Exist tables {tales}")

        self._drop_tables(tales)
        self.connection.commit()
        #connection.close()
        self.list_purchases_name = []
        self.list_inventories_name = []
        self.list_sales_name = []
        self.prefixDBTable = "T_OSL_"
        self.session_id = 1
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
            logging.info(f"Trying drop all tables {str(lsttables)}")
            for c in lsttables:
                self.cursor.execute(f'DROP TABLE {c}')
                logging.info(f"Drop complited -  {c}")


    # def CreateEmptyMaterialsTable(self):
    #     self.cursor.execute(f'''
    #            CREATE TABLE IF NOT EXISTS {self.prefixDBTable}Materials
    #            (
    #            	_sessionID INTEGER  DEFAULT{self.session_id},
    #            	ObjectName TEXT NOT NULL,
    #            	Material TEXT NOT NULL,
    #            	Material_ID INT PRIMARY KEY
    #            	)
    #            	''')
    #     logging.info("Created empty Materials table")
    #     pass
    #
    # def CreateEmptyLocationsTable(self):
    #     self.cursor.execute(f'''
    #                   CREATE TABLE IF NOT EXISTS {self.prefixDBTable}Locations
    #                   (
    #                   	_sessionID INTEGER  DEFAULT{self.session_id},
    #                   	ObjectName TEXT NOT NULL,
    #                   	Location TEXT NOT NULL,
    #                   	Location_ID INT PRIMARY KEY
    #                   	)
    #                   	''')
    #     logging.info("Created empty Locations table")
    #     pass

    def CreateEmptyPurchaseTable(self,name):
        purchasesnametable= self.prefixDBTable+name
        self.list_purchases_name.append(purchasesnametable)
        self.NameToType[purchasesnametable] = OBJECT_TYPE.Purchase
        self.cursor.execute(f'''
        CREATE TABLE  IF NOT EXISTS {self.prefixDBTable}Purchases 
        (
        	_sessionID INTEGER  DEFAULT{self.session_id},
			ObjectName TEXT NOT NULL,
			TimePeriod TEXT NOT NULL,
			Location TEXT NOT NULL,
			ItemDescription TEXT NOT NULL,
			CostPerUnitFactor REAL DEFAULT 0,
			CostPerUnitAdd REAL DEFAULT 0,
			MaxUnitsFactor REAL DEFAULT 0,
			MaxUnitsAdd REAL DEFAULT {MAX_REAL_STR},
			Row_ID INTEGER PRIMARY KEY
        )
        ''')
        logging.info("Created empty Purchase table ")
    def CreateEmptyInventoryTable(self,name):
        inventorynametable = self.prefixDBTable + name
        self.list_inventories_name.append(inventorynametable)
        self.NameToType[inventorynametable] = OBJECT_TYPE.Inventory
      # self.cursor.execute(f"  PRAGMA     foreign_keys = on;")
        self.cursor.execute(f'''               
                CREATE TABLE IF NOT EXISTS {self.prefixDBTable}Invetories
                (
                    _sessionID INTEGER  DEFAULT{self.session_id},
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
        logging.info("Created empty Inventoey table ")
# constraint Location_ID FOREIGN KEY (Location_ID) REFERENCES {self.prefixDBTable}Locations(Location_ID),
# constraint Material_ID FOREIGN KEY (Material_ID) REFERENCES {self.prefixDBTable}Materials(Material_ID)


    def CreateEmptySalesTable(self,name):
        salesnametable = self.prefixDBTable + name
        self.list_sales_name.append(salesnametable)
        self.NameToType[salesnametable] = OBJECT_TYPE.Sales
        self.cursor.execute(f'''               
        CREATE TABLE IF NOT EXISTS {self.prefixDBTable}Sales
        (
            _sessionID INTEGER  DEFAULT{self.session_id},
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
            Row_ID INTEGER PRIMARY KEY
        )''')
    logging.info("Created empty Sales Table ")

    def CreateEmptyLink(self,nameFrom,nameTo,typeLink):
        pass

