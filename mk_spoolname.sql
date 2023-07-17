
with function f_spoolname return varchar is
  vc_fn varchar2(30) := 'dflt_fname';
  con_id number := 0 ;
  begin
    
    return vc_fn ;
  end;
select '  Define report_name = ' || f_spoolname() 
       || '_YYMMDD_HH24MI' from dual ;
/

-- use this to define dbid: CDB or PDB.
select sys_context('USERENV', 'CON_ID'), 
case to_number ( sys_context('USERENV', 'CON_ID') )
  when 0 then ( d.dbid )
  when 1 then ( d.dbid ) 
  else ( select p.dbid from v$pdbs p ) 
  end dbid
from v$database d;

-- and some metric.. 
-- turn this into a view ... snap_pairs
with  snaps as (
select /*+ materialize */
  s1.snap_id as snap1
, s2.snap_id as snap2
,  ( cast ( s1.end_interval_time as date)  -   cast ( s1.begin_interval_time as date )) * (24*3600)  as secs
, s2.instance_number 
, s2.dbid
, s2.startup_time
, s2.begin_interval_time, s2.end_interval_time 
--, s2.* 
from dba_hist_snapshot s1
   , dba_hist_snapshot s2
where 1=1 
and s1.dbid = s2.dbid
and s1.startup_time = s2.startup_time
and s1.instance_number = s2.instance_number
and s2.begin_interval_time = s1.end_interval_time  /* only adjacent */
--and s2.begin_interval_time > ( sysdate - 1 )       /* limit the set */
)
select '@awr12 ' || s.snap1 || ' ' || s.snap2 as snaps
, to_char ( s.end_interval_time, 'DY DD HH24:MI' ) as end_dt
, s2.value, s1.value 
, round ( (s2.value - s1.value ) / s.secs , 2 ) p_sec
,s.dbid 
from
  snaps s    
, dba_hist_sysstat s1
, dba_hist_sysstat s2
where 1=1
and s.snap1 = s1.snap_id
and s.dbid = s1.dbid
and s.instance_number = s1.instance_number
and s.snap2 = s2.snap_id
and s.dbid = s2.dbid
and s.instance_number = s2.instance_number
and s1.stat_name = s2.stat_name   /* same stat, id is faster? */
and s1.stat_id   = s2.stat_id
and s1.stat_name like 'redo size'   /* looking for.... */
--and s.snap2=626
order by s.begin_interval_time desc ;

