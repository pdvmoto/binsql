doc
    info08_v7.sql

    Tablespace Parameters and Usage

Note: In Oracle 7 not a lot of segment mangement is possible as in 8i or 9i

#

set head on
set linesize 110
set pages 100
col tablespace_name format a12 head TABLESPACE|NAME
col initial_extent  format 999999   heading 'INITIAL|EXTENT|SIZE'
col next_extent     format 99999    heading ' NEXT |EXTENT|SIZE'
col min_extents     format 999      heading 'MIN|EXT'
col extents         format 999999   heading 'TOTAL  |EXTENTS'
rem col min_extlen head MIN|EXTLEN
rem col extent_management head EXTENT|MANAGEMENT
rem col allocation_type format a10 head ALLOCATION|TYPE
rem col plugged_in format a7 head PLUGGED|IN
rem col segment_space_management format a10 head SEGMENT|SPACE|MANAGEMENT
select  tablespace_name        
, initial_extent/1024 initial_extent
, next_extent/1024 next_extent
, min_extents
--, min_extlen
, contents
--, logging
--, extent_management
--, allocation_type
--, plugged_in
--, segment_space_management         
from dba_tablespaces
;

prompt
