doc
	info02.sql

	Sizing info: Sizes and Kb usage of tablespaces
#

set heading on
set feedback off
set lines 80

column	tablespace_name format a30
column	mfree		format 999,999,999
column	mused		format 999,999,999
column	mtotal		format 999,999,999
column	perc_free	format 999.99

select  ts.tablespace_name 
     , df.free mFree 
     , ts.total - df.free as mused
     , ts.total mtotal
     , 100 * (df.free) / ts.total perc_free
from ( select sum ( t.bytes /( 1024 * 1024 )) total, t.tablespace_name tablespace_name  
       from dba_data_files t
       group by t.tablespace_name ) ts
   , ( select sum ( f.bytes / ( 1024 * 1024)) free, f.tablespace_name
       from dba_free_space f
       group by f.tablespace_name ) df
where df.tablespace_name = ts.tablespace_name       
order by 1 ;

set head off

column	smfree		format 999,999,999
column	smused		format 999,999,999
column	smtotal		format 999,999,999
column	sperc_free	format 99.99 head perc_free

select '                               '||'------------'||' '||'------------'||' '||'------------'||' '||'---------' from dual;
select '                        Total:', sum (mfree) smfree
,sum(mused) smfree, sum(mTotal) smused, 100* sum(mfree) / sum(mTotal) sPerc_free 
from
(
select  ts.tablespace_name 
     , df.free mFree 
     , ts.total - df.free as mused
     , ts.total mtotal
from ( select sum ( t.bytes / ( 1024 * 1024 )) total, t.tablespace_name tablespace_name  
       from dba_data_files t
       group by t.tablespace_name ) ts
   , ( select sum ( f.bytes / ( 1024 * 1024)) free, f.tablespace_name
       from dba_free_space f
       group by f.tablespace_name ) df
where df.tablespace_name = ts.tablespace_name        )
;

set heading on
set feedback on
clear columns
prompt
