import slimit
import datetime
import shutil

copy_to_bacchus = True

if copy_to_bacchus:
  bacchus_path = 'B:/bsouthga/UrbanTemplates/Map/'
  file_list = [
    'index.html',
    'urban.map.js',
    'css/urban.map.css'
  ]
  for f in file_list:
    shutil.copyfile(f, bacchus_path + f)