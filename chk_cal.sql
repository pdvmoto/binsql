
spool chk_cal_06May

@info02

@info06

@info04

spool off

-- some additional stuff, get separate sqlfile..

-- counv mview logs.

spool calp_mview_logs_06May

@chk_cal_mlogs

spool off

-- need monitoring for size:
 -- tms.documents - blob
 -- esb.inboundactivities - blob

-- need monitoring for full-scans:
 -- esb.filetracker
 -- c_huisman.Requestline
 -- c_huisman.requestheader
 -- tms.goods
 -- tms.documents
 -- tms.party
 -- stdcom.address
 -- ... more to follow


-- documents
select trunc ( last_update_date) day, count (*) nr_docs from xxyss_tms.document 
group by trunc ( last_update_date)
order by 1  desc 
;

-- esb
select trunc ( documentdate) day, count (*) nr_docs from xxyss_esb.INBOUNDACTIVITYFILES
group by trunc ( documentdate)
order by 1  desc 
;

select trunc ( createdatetime) day, count (*) nr_docs from xxyss_esb.filetracker
group by trunc ( createdatetime)
order by 1  desc 
;

-- cost of full-scans, these tables need limiting..
select object_owner, object_name, sum ( cost)  
from v$sql_plan
where 1=1
and object_name is not null
and object_owner <> 'SYS'
and options = 'FULL'
--and operation = 'TABLE ACCESS'
and cost is not null
group by object_owner, object_name
order by 3 desc 
;

spool off
