
COLUMN	t_space		FORMAT A8
COLUMN	kfree		FORMAT 9999999999
COLUMN	kused		FORMAT 9999999999
COLUMN	ktotal		FORMAT 9999999999
COLUMN	perc_free	FORMAT 999.99

set doc off
/*
** free-space per tablespace (before 7.3)
**
**
SELECT v_total.tablespace_name  t_space
, nvl ( kbytes_free, 0 )        Kfree
, nvl ( kbytes_used, 0)         Kused
, kbytes_total                  Ktotal
, 100 * nvl ( kbytes_free, 0 ) / kbytes_total   perc_free
FROM v_free, v_used , v_total
WHERE v_used.tablespace_name (+) = v_total.tablespace_name
AND   v_free.tablespace_name (+) = v_total.tablespace_name
/

/*
** NEW : free-space per tablespace
** with recursive queries (avoid cv_space under sys)
*/

set heading on
set doc on

doc
	Sizing info: Sizes and usage of tablespaces
#
SELECT 	v_total.tablespace_name 	 					t_space
	, 	nvl ( kbytes_free, 0 )        					Kfree
	, 	nvl ( kbytes_used, 0)         					Kused
	, 	kbytes_total                  					Ktotal
	, 	100 * nvl ( kbytes_free, 0 ) / kbytes_total   	perc_free
FROM 	(	SELECT 	tablespace_name
				,	SUM(bytes)/1024 	as 	Kbytes_free
			FROM 	dba_free_space
			GROUP BY tablespace_name					) 	v_free
, 		(	SELECT 	tablespace_name
				,	SUM(bytes)/1024 	as	Kbytes_used
			FROM 	dba_extents
			GROUP BY tablespace_name					)	v_used 
,		(	SELECT tablespace_name
				,	sum(bytes)/1024 	as	Kbytes_total
			FROM dba_data_files
			GROUP BY tablespace_name					) 	v_total
WHERE v_used.tablespace_name (+) = v_total.tablespace_name
AND   v_free.tablespace_name (+) = v_total.tablespace_name
/
