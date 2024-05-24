from openpyxl import load_workbook


class OLBaseObject(object):
    # Constructor
    def __init__(self,BaseModel,ObjName):
        self.BaseModel = BaseModel
        self.ObjName = ObjName
    def __AddRow(self,ObjName,MapNameValues):
        strnames = ''
        strvalues = ''
        for i in MapNameValues.keys():
            strnames=strnames +','+i
            if type(MapNameValues[i])==str:
                strvalues = strvalues + ',' + '"'+str(MapNameValues[i])+'"'
            else:
                strvalues = strvalues + ',' + str(MapNameValues[i])


        sql = f'''INSERT INTO {self.m_nameTable}(ObjectName,_sessionID{strnames})
                     VALUES("{ObjName}",{self.BaseModel.m_session_id}{strvalues}) '''
        self.BaseModel.cursor.execute(sql)
        pass

    def AddObject_Rows(self, xlsxfile):
        wb = load_workbook(xlsxfile)
        sheet = wb.get_sheet_by_name('Sheet1')
        MapNameValues= {}

        for ir in range(sheet.max_row-1):
            MapNameValues.clear()
            for ic in range(sheet.max_column):
                 namecolRL=sheet.cell(row=1, column=ic+1).value
                 namecolOL=self.m_mapper.getRL2OL(namecolRL)
                 if namecolOL is None: # This columnnane not used in OL Engeen
                    continue
                 value = sheet.cell(row=ir+2, column=ic + 1).value
                 MapNameValues[namecolOL]=value
            self.__AddRow(self.ObjName,MapNameValues)
        self.BaseModel.connection.commit()