select * from alertlog
where originating_timestamp > (sysdate - 10)
and message_text like '%00700%';
                                                                               
