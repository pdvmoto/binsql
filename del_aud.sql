rem delete audit records for bdpint etc..

set timing on

select count (*) from sys.aud$;

/* 
 procedural delete to limit commit-size and rbs usage 
*/
declare 
	n_commit_size number := 1000 ;
begin
loop

  delete from sys.aud$ 
  where 1=1              -- userid in ('BDPINT', 'TASKMGR', 'PURGER' )
  and timestamp# < trunc ( sysdate - 10 )
  and rownum <=  n_commit_size ;

  exit when SQL%rowcount < n_commit_size;

  commit;

end loop ;

-- need last commit
commit ;
end;
/

select count (*) from sys.aud$;


