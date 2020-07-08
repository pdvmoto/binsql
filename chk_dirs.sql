
column con format 9999 
column owner format a20
column dirname format A20
column dirpath  format A30

select origin_con_id as con
, owner
, directory_name dirname
, directory_path dirpath
from dba_directories 
order by origin_con_id, owner, directory_name; 

-- now spool files from all dirs..

set ver off
set head off
set feedb off

spool do_dirs

select '@dir ' || directory_name 
from dba_directories 
where directory_name not in (
  'OPATCH_INST_DIR'
, 'OPATCH_LOG_DIR'
, 'OPATCH_SCRIPT_DIR')
order by origin_con_id, owner, directory_name; 

spool off

set head on
set ver on
set feedb on

-- execute the spooled commands..

@do_dirs.lst 

