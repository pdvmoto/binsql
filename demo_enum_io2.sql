
-- demo_enum_io2.sql: show the activity of the enum-queries...(edited from original)
-- helper file...

set sqlformat default

column sql_id       format A15
column exec         format 999 
column cpu_mcrsec   format 99,999,999 
column ela_mcrsec   format 99,999,999 
column buff_gets    format 99,999
column physrds      format 99,999
column sql_text     format A60 wrap

column enum_name    format A15
column loblength    format 99,999,999 

set linesize 130
set pagesize 100

set autotrace off
set echo on

-- show cpu and buffer gets..

select s.sql_id 
, s.executions exec
, s.cpu_time                cpu_mcrsec
--, s.elapsed_time            ela_mcrsec
, s.buffer_gets             buff_gets
--, s.physical_read_requests  physrds
, s.sql_text
--, s.* 
from v$sql  s
where (  sql_text like '%color_enum%' 
      or sql_text like '%roman_enum%' 
      or sql_text like '%data_enum%' 
      or sql_text like '%data_2lov%' 
      or sql_text like '%into tcol%'
      or sql_text like '%into trom%'
      or sql_text like '%from tcol%'
      or sql_text like '%from trom%' )
  and sql_text not like '%sql_text%'
order by s.sql_text ;

