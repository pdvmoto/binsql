select 
  sys_context('USERENV', 'CON_ID') as con_id, 
  sys_context('USERENV', 'CON_NAME') as con_name 
from dual ;
