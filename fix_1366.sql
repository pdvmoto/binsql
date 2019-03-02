
-- fix_1366, two extra indexes on VLT
-- note the two schemanames, 
-- on ACC the schema is VLTRADER, on prod PCS_VLTRADER .

  
-- drop index pcs_vltrader.vlsend_send_pend_xtra1 ; 
-- drop index     vltrader.vlsend_send_pend_xtra1 ; 
 create index pcs_vltrader.vlsend_send_pend_xtra1 
  on pcs_vltrader.vlsend (sendingdt, pendingdt, sendid ) online
  tablespace pcs_index; 

 create index vltrader.vlsend_send_pend_xtra1 
  on vltrader.vlsend (sendingdt, pendingdt, sendid ) 
  tablespace pcs_index; 

-- indexes ... startndt + status + direction + vlserial. order, tbd
-- drop index pcs_vltrader.vltr_ssds_xtra1 ;
-- drop index     vltrader.vltr_ssds_xtra1 ;
create index pcs_vltrader.vltr_ssds_xtra1 
  on pcs_vltrader.vltransfers ( startndt, direction, status, vlserial )
  tablespace pcs_index ;

create index vltrader.vltr_ssds_xtra1 
  on vltrader.vltransfers ( startndt, direction, status, vlserial )
  tablespace pcs_index ;
