import configparser
config = configparser.ConfigParser()
config.optionxform=str
config['radio'] = {'New Message':'< SMS_ACKNOWLEDGE'}
config['logcat'] = {'New TextPlus Message':'Displayed com.gogii.textplus'}
with open('Notify.ini', 'w') as configfile:
      config.write(configfile)

