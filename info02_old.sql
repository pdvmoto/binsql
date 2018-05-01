set doc off

/*
** Free-space per tablespace with recursive queries
** Possible from V7.3 and higher versions.
*/

set doc on

doc
	info02.sql

	Sizing info: Sizes and Kb usage of tablespaces
#

column	table_space	format a18
column	kfree		format 99999999999
column	kused		format 99999999999
column	ktotal		format 99999999999
column	perc_free	format 999.99
set heading on
set feedback off
set lines 80
select 	v_total.tablespace_name 	 					table_space
	, 	nvl ( kbytes_free, 0 )        					Kfree
	, 	nvl ( kbytes_used, 0)         					Kused
	, 	kbytes_total                  					Ktotal
	, 	100 * nvl ( kbytes_free, 0 ) / kbytes_total   	perc_free
from 	(	select 	tablespace_name
				,	sum(bytes)/1024 	as 	Kbytes_free
			from 	dba_free_space
			group by tablespace_name					) 	v_free
, 		(	select 	tablespace_name
				,	sum(bytes)/1024 	as	Kbytes_used
			from 	dba_extents
			group by tablespace_name					)	v_used 
,		(	select tablespace_name
				,	sum(bytes)/1024 	as	Kbytes_total
			from dba_data_files
			group by tablespace_name					) 	v_total
where v_used.tablespace_name (+) = v_total.tablespace_name
and   v_free.tablespace_name (+) = v_total.tablespace_name
/

set heading off

select 	'                   ------------ ------------ ------------ ---------             '
,       '           Total :'                	 					t_space
	, 	nvl ( kbytes_free, 0 )        					Kfree
	, 	nvl ( kbytes_used, 0)         					Kused
	, 	kbytes_total                  					Ktotal
	, 	100 * nvl ( kbytes_free, 0 ) / kbytes_total   	perc_free
from 	(	select 	sum(bytes)/1024 	as 	Kbytes_free
			from 	dba_free_space  					) 	v_free
, 		(	select 	sum(bytes)/1024 	as	Kbytes_used
			from 	dba_extents     					)	v_used 
,		(	select  sum(bytes)/1024 	as	Kbytes_total
			from dba_data_files         				) 	v_total
--where v_used.tablespace_name (+) = v_total.tablespace_name
--and   v_free.tablespace_name (+) = v_total.tablespace_name
/

set heading on
set feedback on
clear columns
prompt
