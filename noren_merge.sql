

create table t (
      id integer not null
        constraint t_pk primary key,
      data varchar2(100),
      last_operation varchar2(10)
    );

insert into t (id,data)
      select rownum,'init'
      from dual
      connect by level<=5;

commit ; 

create procedure with_merge (
      p_id in t.id%type,
      p_data in t.data%type
    ) as
    begin
      merge into t
      using dual
      on (t.id = p_id)
      when matched then
       update set data = p_data,
                  last_operation = 'update'
     when not matched then
       insert (id,data,last_operation)
       values (p_id,p_data,'insert');
   end with_merge;
/


create procedure without_merge (
      p_id in t.id%type,
      p_data in t.data%type
    ) as
    begin
      insert into t (id,data,last_operation)
      values (p_id,p_data,'insert');
    exception
      when dup_val_on_index then
       update t
       set t.data = p_data,
           t.last_operation = 'update'
       where t.id = p_id;
   end without_merge;
/

begin
        with_merge(1,'with_merge');
        with_merge(6,'with_merge');
        without_merge(2,'without_merge');
        without_merge(7,'without_merge');
        commit;
end;
/

select * from t order by id;

--
-- In session 1 
--
exec dbms_application_info.set_client_info('Session 1')

exec without_merge(8,'without_merge in session 1')

prompt  "now go to session two..."

set doc on

doc  

go into sess 2 ***

--
-- In session 2
-- 
23ai> exec dbms_application_info.set_client_info('Session 2')


exec without_merge(8,'without_merge in session 2')

#

set doc off

accept abc prompt "past the above into sess 2 "

commit ;

accept abc prompt "now commit sess 2 all expected behaviour"


