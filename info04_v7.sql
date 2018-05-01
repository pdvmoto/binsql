doc
    info04_v7.sql

    File overview: datafiles, logfiles, controlfiles rollbacksegments.
#

column datafile_name        format a43 wrap
column tablespace_name      format a15
column logfile_name         format a43 wrap
column controlfile_name     format a43 wrap
column filesize             format a13  heading 'SIZE: Mb + Kb'
column status               format a6 trunc
column contents		    format a4 trunc heading TEMP
column rollbacksegment      format a16

set heading on
set pagesize 60
set linesize 105
select  df.file_name     datafile_name
, lpad(trunc(df.bytes/(1024*1024)),8)
||lpad((df.bytes/(1024*1024) - trunc(df.bytes/(1024*1024))) * 1024,5) filesize
, df.tablespace_name
, decode(dt.contents, 'TEMPORARY', dt.contents, NULL) contents
, vd.status
from dba_data_files df
,    dba_tablespaces dt
,    v$datafile      vd
where df.tablespace_name = dt.tablespace_name
and  vd.file# = df.file_id
order by df.file_id
/

set heading off
set feedback off
select '                          Total of datafiles'
||lpad(trunc(sum(df.bytes)/(1024*1024)),8)
||lpad((sum(df.bytes)/(1024*1024) - trunc(sum(df.bytes)/(1024*1024))) * 1024,5)
from dba_data_files df
/

PROMPT
PROMPT
PROMPT Using a Tempfile: Only Possible from 8i And Up
set heading on
set feedback on
column tempfile_name        format a43 wrap
column status               format a10 trunc
column autoextensible       format a14
select dtf.file_name     tempfile_name
, lpad(trunc(dtf.bytes/(1024*1024)),8)
||lpad((dtf.bytes/(1024*1024) - trunc(dtf.bytes/(1024*1024))) * 1024,5) filesize
, dtf.tablespace_name
, dtf.status
, dtf.autoextensible
from dba_temp_files dtf
order by 1
/

set feedback off
set heading on
column status               format a16 trunc
column logsize              format a8  heading 'SIZE: MB'
select member					logfile_name
,      lpad((v$log.bytes/(1024*1024)),8)	logsize
,      v$logfile.group#
,      v$log.status
from v$logfile, v$log
where v$log.group# = v$logfile.group#
/

set heading off

select '                          Total of logfiles '
||lpad(sum(members*bytes/(1024*1024)),8)
from v$log
/

set heading on

set doc off
/* 

V$LOG: The following defines values in the log STATUS column. 

STATUS           Meaning  
UNUSED           Indicates the online redo log has never been written to. This
                 is the state of a redo log that was just added, or just after a
                 RESETLOGS, when it is not the current redo log.  
CURRENT          Indicates this is the current redo log. This implies that the 
                 redo log is active. The redo log could be open or closed.  
ACTIVE           Indicates the log is active but is not the current log. It is 
                 needed for crash recovery. It may be in use for block recovery. 
                 It might or might not be archived.  
CLEARING         Indicates the log is being recreated as an empty log after an 
                 ALTER DATABASE CLEAR LOGFILE command. After the log is cleared, 
                 the status changes to UNUSED.  
CLEARING_CURRENT Indicates that the current log is being cleared of a closed 
                 thread.The log can stay in this status if there is some failure 
                 in the switch such as an I/O error writing the new log header.  
INACTIVE         Indicates the log is no longer needed for instance recovery. It
                 may be in use for media recovery. It might or might not have 
                 already been archived.  


V$CONTROLFILE: This view lists the names of the control files.

STATUS -- VARCHAR2(7) INVALID if the name cannot be determined, which should not occur

*/
set doc on
col controlfile_name format a63 wrap
select  name	 		controlfile_name
    ,   NVL(status, 'OK')       status
from v$controlfile
/

set lines 115
col rollbacksegment format a10      heading 'ROLLBACK|or UNDO|SEGMENT'
col initial_extent  format 999999   heading 'INITIAL|EXTENT|SIZE'
col next_extent     format 99999    heading ' NEXT |EXTENT|SIZE'
col min_extents     format 999      heading 'MIN|EXT'
col extents         format 999999   heading 'TOTAL  |EXTENTS'
col rssize          format 9999999  heading 'TOTAL| SIZE'
col optsize         format 999999   heading 'OPTIMAL|SIZE'
col hwmsize         format 99999999 heading 'HIGHWATER|MARKSIZE'
col max_extents     format 999999   heading 'MAX    |EXTENTS'
col xacts           format 999      heading 'ACT|TRX'
col tablespace      format a10
col owner           format a6
col status          format a6
select	drs.segment_name rollbacksegment
,       drs.initial_extent/1024 initial_extent
,       drs.next_extent/1024 next_extent
,       drs.min_extents
,       vrs.extents
,       vrs.rssize/1024 rssize
,       vrs.optsize/1024 optsize
,       vrs.hwmsize/1024 hwmsize
,       drs.max_extents
,       vrs.xacts
,	drs.tablespace_name tablespace
,       drs.owner
,	drs.status
from	dba_rollback_segs drs
,       v$rollstat        vrs
,       v$rollname        vrn
where drs.segment_name = vrn.name
and   vrn.usn          = vrs.usn
;

PROMPT
PROMPT All Sizes off Rollback or Undo Segments are in Kilobytes

clear columns
prompt
