
doc
	info07_files.sql : search file-locations from parameters

	Remarks :
	- adhoc clone of info07... 
	- Do not consider this list complete,
	  and do manually check te init.ora file and the OH locaions
	- dflt=yes means the value was not set explicit
	- sesmod and sysmod: the value CAN be modified by a DBA
	  but this list does no show history 
	- Verify if an init.ora is used or an spfile.
	  oracle recommends spile, but ini.ora tends to be more manageable.

#

set pagesize 75
set linesize 100


column name		  format A35 trunc
column value		format A15 wrap
column nls_value	format A30 wrap
column dflt	   	format A4 justify left
column Sesmod		format A3 trunc head sesmod justify right
column sysmod		format A6 trunc head sysmod justify right
column pdbmod		format A3 trunc head pdb    justify right

column descript		format A26 trunc

column fpname		  format A20 trunc
column fpvalue		format A55 trunc


SELECT 	p.name				 fpname
  , decode (type
           , 3, to_char ( to_number ( value), '99,999,999,999' )
           , 6, to_char ( to_number ( value), '99,999,999,999' ) 
           , value -- lpad ( value, 55 )
           )                                                          fpvalue
--, 	decode ( p.ISDEFAULT      , 'TRUE'  , ''      , '  No' )        dflt
--,     decode ( isses_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  sesmod
--,     decode ( ispdb_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  pdbmod
  ,     decode ( issys_modifiable , 'FALSE' , ''
                                  , issys_modifiable )                sysmod
--  , 	substr ( p.DESCRIPTION, 1 , 23 ) || '...'		descript
FROM v$parameter p
WHERE 1 = 1
and   (  name like '%db_cre%' 
      or name like 'audit_fi%' 
      or name like '%flash%'
      or name like '%dest%'
      or value like '%home%'  /* anything in home may be unwanted */
      or value like '/%'
      )
and  type =   2        /* vc, text only */ 
and value != 'enable'  /* skip the online-log-dest */ 
and name not like 'cursor_bind%'   /* skip capture-dest */
order by name ;

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
  ,     decode ( ispdb_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  pdbmod
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
  ,     decode ( ispdb_modifiable , 'TRUE'  , '  Yes' , 'FALSE', '')  pdbmod
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

-- old code below 

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
