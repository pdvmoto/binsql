
doc
	info07.sql
	Relevant init-parameters 
	mostly performance oriented 
	do not consider this list complete,
	and do manually check te init.ora file.
#

column name			format A30 trunc
column value		format A21
column descript		format A26
column def			format A7


SELECT 	p.name				
  , 	lpad ( ltrim ( p.VALUE ), 20 )						value
  , 	decode ( p.ISDEFAULT, 'TRUE', 'Dflt', 'NonDflt' )	def
--  , 	substr ( p.DESCRIPTION, 1, 23 ) || '...'			descript
FROM v$parameter p
WHERE 1 = 1
and (      (p.name Like 'always_anti%') 
	OR (p.name Like 'audit_t%')	   
        OR (p.name Like 'char%')	   
        OR (p.name Like 'checkpoint%')	   
        OR (p.name Like 'cpu%')    
        OR (p.name Like 'cursor%') 
	OR (p.name Like 'db_block_b%') 
	OR (p.name Like 'db_block_s%')  
	OR (p.name Like 'db_block%')  
	OR (p.name Like 'db_fi%') 
	OR (p.name Like 'db_wr%') 
	OR (p.name Like 'global%') 
	OR (p.name Like 'hash%') 
	OR (p.name Like 'java%') 
	OR (p.name Like 'job%') 
	OR (p.name Like 'large%') 
	OR (p.name Like 'log_archive_b%') 
	OR (p.name Like 'log_bu%') 
	OR (p.name Like 'log_ch%') 
	OR (p.name Like 'log_s%') 
	OR (p.name Like 'nls_date%') 
	OR (p.name Like 'opti%') 
	OR (p.name Like 'open%') 
	OR (p.name Like 'proc%') 
	OR (p.name Like 'shared%') 
	OR (p.name Like 'snap%') 
	OR (p.name Like 'sort_a%') 
	OR (p.name Like 'spin%') 
	OR (p.name Like 'seq%') 
	)
ORDER BY p.name
/

doc

	Nls and date related parameters.
#
SELECT 	p.name				
  , 	lpad ( ltrim ( p.VALUE ), 20 )						value
  , 	decode ( p.ISDEFAULT, 'TRUE', 'Dflt', 'NonDflt' )	def
--  , 	substr ( p.DESCRIPTION, 1, 23 ) || '...'			descript
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
  , 	lpad ( ltrim ( p.VALUE ), 20 )						value
  , 	decode ( p.ISDEFAULT, 'TRUE', 'Dflt', 'NonDflt' )	def
--  , 	substr ( p.DESCRIPTION, 1, 23 ) || '...'			descript
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

column name			format A27 trunc
column value		format A40
column def			format A7

SELECT 	p.name				
  , 	p.VALUE												value
  , 	decode ( p.ISDEFAULT, 'TRUE', 'Dflt', 'NonDflt' )	def
FROM v$parameter p
WHERE 1 = 1
and (  (p.name Like 'log_archive_d%') 
	OR (p.name Like 'log_archive_f%') 
	OR (p.name Like 'audit_file%') 
	OR (p.name Like '%dump_dest%') 
	OR (p.name Like '%dest%') 
	)
ORDER BY p.name
/

doc
	show sga sizes

#
column value format 999,999,999

select * from v$sga
/
