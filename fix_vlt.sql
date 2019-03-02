/***
  1st problem sql to fix: 
SELECT sendingdt, pendingdt, SendID
FROM pcs_vltrader.VLSend
WHERE SendingDT IS NOT NULL
  OR PendingDT IS NOT NULL;
  
SELECT sendingdt, pendingdt, SendID
FROM vltrader.VLSend
WHERE SendingDT IS NOT NULL
  OR PendingDT IS NOT NULL;
****/
  
-- drop index pcs_vltrader.vlsend_send_pend_xtra1 ; 
 create index pcs_vltrader.vlsend_send_pend_xtra1 
  on pcs_vltrader.vlsend (sendingdt, pendingdt, sendid ) 
  tablespace pcs_index; 


/****
  2nd problem, fixable:
SELECT count(distinct vlserial) as VLT_COUNTER
FROM vltransfers vlt
WHERE vlt.startndt > sysdate - :"SYS_B_0" / :"SYS_B_1"
  AND status = :"SYS_B_2"
  AND direction = :"SYS_B_3"

SELECT count(distinct vlserial) as VLT_COUNTER
FROM pcs_vltrader.vltransfers vlt
WHERE vlt.startndt > sysdate - 5/1440 
  AND status = 'Success'
  AND direction = 'send'
***/

-- indexes ... startndt + status + direction + vlserial. order, tbd
--drop index pcs_vltrader.vltr_ssds_xtra1 ;
create index pcs_vltrader.vltr_ssds_xtra1 
  on pcs_vltrader.vltransfers ( startndt, status, direction, vlserial )
  compress 2
  tablespace pcs_index ;
