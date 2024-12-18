import os
#GLOBAL_LOG_DIR = os.path.join(os.path.expanduser("~"), "tmpdata")
GLOBAL_LOG_DIR = os.path.abspath(os.path.dirname(__file__))
class LogSettings:
    pathtolog = os.path.join(GLOBAL_LOG_DIR,'../tmpdata/logfile.log')