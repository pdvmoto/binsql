

select t.startdt, t.enddt, t.startndt, t.transferid, t.origname, t.* 
from pcs_vltrader.vltransfers  t 
where 1=1 
and t.startndt is null
and t.transferid like  'SSH FTP%'
--and rownum < 10000
--and origname ='510534654P.edi'
order by t.transferid desc  ;


-- check if VLTF with nulls is in O : zero, none
select vt.transferid, vt.startndt , vo.*
from pcs_vltrader.vltransfers vt
   , pcs_vltrader.vloutgoing vo
where vo.transferid  = vt.transferid 
and vt.startndt is null
;

-- check if VLTF with nulls is in incoming : 131000, and 390.000 properties.
select vt.transferid, vt.startndt , vi.*, vip.*
from pcs_vltrader.vltransfers vt
   , pcs_vltrader.vlincoming vi
   , PCS_VLTRADER.vlincomingproperties vip
where vi.transferid  = vt.transferid 
  and vi.transferid  = vip.transferid
  and vi.vlserial = vip.vlserial
and vt.startndt is null
order by vt.transferid, vi.vlserial, vip.name;

-- check if VLTF with nulls is in incoming : 131000, and 390.000 properties.
select vt.transferid, nvl ( to_char ( vt.startndt), '-----------' ) as ndt , vi.*, vip.name, vip.value, nvl ( to_char ( vt.startndt), '-----------' ) as ndt
from pcs_vltrader.vltransfers vt
   , pcs_vltrader.vlincoming vi
   , PCS_VLTRADER.vlincomingproperties vip
where vi.transferid  = vt.transferid 
  and vi.vlserial    = vt.vlserial
  and vi.transferid  = vip.transferid
  and vi.vlserial    = vip.vlserial
  --and vt.startndt is null
order by vt.startdt desc , vt.transferid, vi.vlserial, vip.name;




