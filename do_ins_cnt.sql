declare
    /* do_ins_cnt */

	starttime	    date ;
	str 		      varchar2(1000);
  vc_stmnt      Varchar2(1000) ;
	n_cnt     		number;
  n_loops       number ;
  n_max         number := 10000000 ;

begin

  n_loops       := 0 ;
  starttime     := sysdate ;

  for t in (select owner, table_name from all_tables
              where (owner,table_name) not in (select owner,table_name from all_external_tables)
              and owner not in ( 'SYS' )
            UNION ALL
            select owner, view_name from all_views where owner not in ( 'SYS' )
  ) loop

    begin
      vc_stmnt := ' insert /* zz_cnt */ into zz_cnt ( owner, object_name, rec_cnt )  ' 
               || ' select :b_owner, :b_object_name, :b_rec_cnt from dual ' ; 

      -- do some counting, but limit to N rows to avoid runaways on large tables.
      execute immediate 'select /* zz_cnt */ count(*) from '||t.owner||'.'||t.table_name||' t where 1=1 ' into n_cnt ;

      execute immediate vc_stmnt using t.owner , t.table_name, n_cnt ; 

      commit ; /* track progress... */ 

      n_loops := n_loops + 1 ;

    exception   -- overkill, for the moment...
      when others then null;
    end;

  end loop; -- t

dbms_output.put_line ( ' ')  ;
dbms_output.put_line ( 'did zz_cnt ' || to_char ( n_loops ) || ' executes done. ' ) ;

end ;
/
