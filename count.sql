
column object_name format A30
column rec_count   format 999,999,999,999 

-- select count (*) rec_count from &1 ;
-- select count (*) "&1"  from &1 ;

select ' ' || '&&1' || ': ' object_name,   count (*) rec_count  from &&1 ;


