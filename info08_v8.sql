doc
    info08_v8.sql

    Tablespace Parameters and Usage

Note: Segment space management column does not exists in Version 8 dba_tablespaces
      And plugged in tablespace is only possible from 8i on (Not displayed now!)

#

set head on
set linesize 110
set pages 100
col tablespace_name format a12 head TABLESPACE|NAME
col initial_extent  format 999999   heading 'INITIAL|EXTENT|SIZE'
col next_extent     format 99999    heading ' NEXT |EXTENT|SIZE'
col min_extents     format 999      heading 'MIN|EXT'
col extents         format 999999   heading 'TOTAL  |EXTENTS'
col min_extlen head MIN|EXTLEN
col extent_management head EXTENT|MANAGEMENT
col allocation_type format a10 head ALLOCATION|TYPE
col plugged_in format a7 head PLUGGED|IN
rem col segment_space_management format a10 head SEGMENT|SPACE|MANAGEMENT
select  tablespace_name        
, initial_extent/1024 initial_extent
, next_extent/1024 next_extent
, min_extents
, min_extlen
, contents
, logging
, extent_management
, allocation_type
--, plugged_in  -- Only possible in 8i not in 8.0
--, segment_space_management         
from dba_tablespaces
;

prompt
