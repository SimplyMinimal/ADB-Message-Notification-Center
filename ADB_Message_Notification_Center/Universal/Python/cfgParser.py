import configparser
import os.path
#Global Variables
INI_FILE = "Notify.ini"

if not os.path.isfile(INI_FILE):
    config = configparser.ConfigParser()
    config.optionxform=str
    config['radio'] = {'New Message':'< SMS_ACKNOWLEDGE'}
    config['logcat'] = {'New TextPlus Message':'Displayed com.gogii.textplus'}
    with open(INI_FILE, 'w') as configfile:
        config.write(configfile)

