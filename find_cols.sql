

-- use this select to do first check..
select 'select '''||  owner || ''', '''|| table_name ||  ''', ''' ||   column_name || ''' '
|| ', ' ||  column_name || ' as dir '
|| ' from ' || owner||'.'||table_name || ';'
from dba_tab_columns
where column_name like 'FILEDIR%'
  or column_name like 'FILELOC%'
  or column_name like 'DONEDI%'
  or column_name like 'ERRORDIR%'; 


-- first need table to store data..
create table col_data as 
select owner, table_name, column_name
from dba_tab_columns 
where 1=0;

alter table col_data  add content varchar2(4000);

--  generate the queries for all relevant columns

set linesize 200
set feedb off

spool do_find_cols

select 'insert into col_data select '''
||  owner || ''', '''|| table_name ||  ''', ''' ||   column_name || ''' '
|| ', ' ||  column_name || ' as content '
|| ' from ' || owner||'.'||table_name || ';'
from dba_tab_columns
where column_name like 'FILEDIR%'
  or column_name like 'FILELOC%'
  or column_name like 'DONEDI%'
  or column_name like 'ERRORDI%'; 


spool off
set feedb on


prompt to generate data, 
prompt @do_find_cols.lst
prompt .
