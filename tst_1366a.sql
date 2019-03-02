
set echo on
set autotrace on
set timing on

spool tst_1366

prompt  1st problem sql to fix: 

  
SELECT sendingdt, pendingdt, SendID
FROM vltrader.VLSend
WHERE SendingDT IS NOT NULL
  OR PendingDT IS NOT NULL;

l
/

  

prompt 2nd problem, fixable:

SELECT count(distinct vlserial) as VLT_COUNTER
FROM vltrader.vltransfers vlt
WHERE vlt.startndt > sysdate - 5/1440 
  AND status = 'Success'
  AND direction = 'send' ;

l

/


spool off
