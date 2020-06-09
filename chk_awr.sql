doc
  chk_awr : check the awr settings.

#

column dbid format 999999999999
column retention_total_minutes format 9999999
column approx_days format A10
column interval_minutes format 999
column topnsql format A10

select c.dbid as dbid
-- , extract  ( minute from c.snap_interval )  as snap_interval_minutes
-- , extract  ( day from c.retention )  as retention_days
, extract  ( minute from c.retention )
  + extract ( hour from c.retention ) * 60 
  + extract ( day from c.retention ) * 24*60 as retention_total_minutes
, '('|| extract  ( day from c.retention )  || ' days)'  approx_days
, extract  ( minute from c.snap_interval )  as interval_minutes
, c.topnsql 
from v$database d
   , dba_hist_wr_control c
where c.dbid = d.dbid
; 

