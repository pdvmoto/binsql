
doc
	info07.sql : Relevant init-parameters 

	Remarks :
	- This list is/was mostly performance oriented.
	- Do not consider this list complete,
	  and do manually check te init.ora file.
	- dflt=yes means the value was not set explicit
	- sesmod and sysmod: the value CAN be modified by a DBA
	  but this list does no show history 
	- Verify if an init.ora is used or an spfile.
	  oracle recommends spile, but ini.ora tends to be more manageable.

#

-- todo for info07: group parameters:
--   - startup : ifile, spfile, control, compatible, db_domain, db_files, db_name, processes
--   -
--   - various files : dump, db_create, shadow_core_dump
--   - memory : shared/large-pool, db_cache%, log_buff, lock_sga , db_files, processes
--     cursor_%.., large_p only if derived value is too large.
--     note : sum(sgastat) <> v$sga.total <> sga_max 
--   - archive dest + standby% stuff, file_name_convert
--   - parallel stuff 
--   - mts: mtx%, dispatchers, shared_server%, max_disp, circuits
--   - performance : sorting, MBRC, bimap, hash, pga, work-area, dbwr, writer..	 dml
--     optimizer%, hash, hi, hs, log_check%, log_file_name%
--     resource, star%
--   - diverse : events, fast_start, reco%, file_mapping, fixed_date (risky), global_names
--   - ??? global_context_pool, max_dump_file_ize, open_cur, dml_l
--   - rac : cluster%, instance%, local_list%, remote_lis%, thread, undo, gc_files
--   - java : investigate...
--   - rbs: rollb, max_roll, undo%..
--   - nls : as is
--   - distributed: open_links, global_names, 
--   - oracle_trace%
--   - parallal%, partition_view%
--   - plsql%, session_max_open_files
--   - recovery_para%
--   - licence%
--   - auditing, remote_login,remote_os, os%, timed_stat, timed_os..
--   - sql_trace
--   - statistcis_level _ investigate!


set pagesize 75


column name		format A35 trunc
column value		format A15 wrap
column dflt		format A4 justify left
column Sesmod		format A6 trunc head sesmod justify right
column sysmod		format A6 trunc head sysmod justify right

column descript		format A26 trunc



SELECT 	p.name				
  , decode (type
           , 3, to_char ( to_number ( value), '99,999,999,999' )
           , 6, to_char ( to_number ( value), '99,999,999,999' ) 
           , lpad ( value, 15 )
           )                                                          value
  , 	decode ( p.ISDEFAULT      , 'TRUE'  , ''      , '  No' )      dflt
  ,     decode ( isses_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  sesmod
  ,     decode ( issys_modifiable , 'FALSE' , ''
                                  , issys_modifiable )                sysmod
--  , 	substr ( p.DESCRIPTION, 1 , 23 ) || '...'		descript
FROM v$parameter p
WHERE 1 = 1
and (      (p.name Like 'always_anti%') 
	OR (p.name Like '%')	   
	OR (p.name Like 'aq%')	   
	OR (p.name Like 'arch%')	   
	OR (p.name Like 'audit%')	   
        OR (p.name Like 'char%')	   
        OR (p.name Like 'checkpoint%')	   
        OR (p.name Like 'cpu%')    
        OR (p.name Like 'cursor%') 
	OR (p.name Like 'db_block_b%') 
	OR (p.name Like 'db_block_s%')  
	OR (p.name Like 'db_block%')  
        OR (p.name Like 'db_crea%')    
	OR (p.name Like 'db_%cach%')  
	OR (p.name Like 'db_fi%') 
	OR (p.name Like 'db_wr%') 
	OR (p.name Like 'dbwr%') 
	OR (p.name Like 'global%') 
	OR (p.name Like 'hash%') 
	OR (p.name Like 'java%') 
	OR (p.name Like 'job%') 
	OR (p.name Like 'large%') 
	OR (p.name Like '%keep%') 
	OR (p.name Like 'log_archive_b%') 
	OR (p.name Like 'log_bu%') 
	OR (p.name Like 'log_ch%') 
	OR (p.name Like 'log_s%') 
	OR (p.name Like 'mts%') 
	OR (p.name Like 'nls_date%') 
	OR (p.name Like 'opti%') 
	OR (p.name Like 'open%') 
	OR (p.name Like 'os%') 
	OR (p.name Like 'pga%') 
	OR (p.name Like 'proc%') 
	OR (p.name Like '%passw%') 
	OR (p.name Like 'shared%') 
	OR (p.name Like 'sga%') 
	OR (p.name Like 'snap%') 
	OR (p.name Like 'sort_a%') 
	OR (p.name Like '%spin%') 
	OR (p.name Like 'seq%')  
	OR (p.name Like 'session_c%')  
	OR (p.name Like 'star%') 
	OR (p.name Like 'timed_sta%') 
	OR (p.name Like 'undo%') 
	OR (p.name Like 'work%')
	OR ( substr ( p.name, 1, 1) = '_' )  -- show any hidden params
 	)
ORDER BY p.name
/


doc

	generic database parameters	
#
--   - startup : ifile, spfile, control, compatible, db_domain, db_files, db_name, processes

SELECT 	p.name				
  , decode (type
           , 3, to_char ( to_number ( value), '99,999,999,999' )
           , 6, to_char ( to_number ( value), '99,999,999,999' ) 
           , lpad ( value, 15 )
           )                                                          value
 , 	decode ( p.ISDEFAULT      , 'TRUE'  , ''      , '  No' )      dflt
  ,     decode ( isses_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  sesmod
  ,     decode ( issys_modifiable , 'FALSE' , ''
                                  , issys_modifiable )                sysmod
--  , 	substr ( p.DESCRIPTION, 1 , 23 ) || '...'		      descript
FROM v$parameter p
WHERE 1 = 1
and (      (p.name Like 'compatible%')
     -- OR (p.name Like 'control_file%')	   
	OR (p.name Like 'db_d%')
     -- OR (p.name Like 'db_files%')	
	OR (p.name Like 'db_na%')	
        OR (p.name Like 'ifile%')	   
	OR (p.name Like 'optimizer_mode%')	 	   
	OR (p.name Like 'spf%')	   
     -- OR (p.name Like 'processes%')	   
	)
ORDER BY p.name
/


doc

	db_cache related parameters	
#

SELECT 	p.name				
  , decode (type
           , 3, to_char ( to_number ( value), '99,999,999,999' )
           , 6, to_char ( to_number ( value), '99,999,999,999' ) 
           , lpad ( value, 15 )
           )                                                          value
  , 	decode ( p.ISDEFAULT      , 'TRUE'  , ''      , '  No' )      dflt
  ,     decode ( isses_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  sesmod
  ,     decode ( issys_modifiable , 'FALSE' , ''
                                  , issys_modifiable )                sysmod
--  , 	substr ( p.DESCRIPTION, 1 , 23 ) || '...'		      descript
FROM v$parameter p
WHERE 1 = 1
and (   (p.name    in ( 'db_cache_size'
                      , 'db_2k_cache_size'
                      , 'db_4k_cache_size'
                      , 'db_8k_cache_size'
                      , 'db_16k_cache_size'
                      , 'db_32k_cache_size'
        )             )
     OR (p.name Like 'db_cache_ad%')
     OR (p.name Like 'db_block%')
  -- OR (p.name Like 'statistics%')
     OR (p.name Like 'buffer%')
     )
order by p.name
/

	   
doc

	Nls and date related parameters.
#
SELECT 	p.name				
  , decode (type
           , 3, to_char ( to_number ( value), '99,999,999,999' )
           , 6, to_char ( to_number ( value), '99,999,999,999' ) 
           , value 
           )                                                          value
  , 	decode ( p.ISDEFAULT      , 'TRUE'  , ''      , '  No' )      dflt
  ,     decode ( isses_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  sesmod
  ,     decode ( issys_modifiable , 'FALSE' , ''
                                  , issys_modifiable )                sysmod
--  , 	substr ( p.DESCRIPTION, 1 , 23 ) || '...'		      descript
FROM v$parameter p
WHERE 1 = 1
and (      (p.name Like 'nls%') 
	OR (p.name Like '%char%')	   
	OR (p.name Like '%date%')	   
	)
ORDER BY p.name
/

doc

	Parallel execution related init-parameters 
#

SELECT 	p.name				
  , decode (type
           , 3, to_char ( to_number ( value), '99,999,999,999' )
           , 6, to_char ( to_number ( value), '99,999,999,999' ) 
           , value 
           )                                                          value
  , 	decode ( p.ISDEFAULT      , 'TRUE'  , ''      , '  No' )      dflt
  ,     decode ( isses_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  sesmod
  ,     decode ( issys_modifiable , 'FALSE' , ''
                                  , issys_modifiable )                sysmod
--  , 	substr ( p.DESCRIPTION, 1 , 23 ) || '...'		      descript
FROM v$parameter p
WHERE 1 = 1
and (      (p.name Like 'paral%') 
	OR (p.name Like 'paral%')  
    )
and p.name not like 'parallel_server%'
ORDER BY p.name
/

doc

	File-system related init-parameters 
		Help you find dumps and archives.
#

column name		format A27 trunc
column value		format A40
column def		format A7

SELECT 	p.name				
  , 	p.VALUE												value
  , 	decode ( p.ISDEFAULT, 'TRUE', 'Dflt', 'NonDflt' )	def
FROM v$parameter p
WHERE 1 = 1
and (      (1=0) 
	OR (p.name Like 'audit_file%') 
	OR (p.name Like 'control%') 
        OR (p.name Like 'db_crea%')    
	OR (p.name Like '%dump_dest%') 
	OR (p.name Like 'dg%') 
	OR (p.name Like '%dest%') 
	OR (p.name Like 'file%') 
	OR (p.name Like 'gc_file%') 
        OR (p.name Like 'log_archive_d%') 
	OR (p.name Like 'log_archive_f%') 
	OR (p.name Like 'max_dump%') 
	OR (p.name Like 'shadow%') 
	OR (p.name Like 'utl%') 
	)
ORDER BY p.name
/

doc

        show sga size

        note: values may differ from set-parameter (??)
        this is acutal claimed amount.

#

select nvl ( pool, name )                        as name
     , to_char ( sum(bytes),  '999,999,999,999' ) as value
from v$sgastat
where 1=1 -- pool is not null
group by nvl ( pool, name ) 
/

select 'Total SGA'                               as name
     , to_char ( sum(bytes),  '999,999,999,999' ) as value
from v$sgastat
where 1=1 -- pool is not null
group by 'Total SGA'
/
