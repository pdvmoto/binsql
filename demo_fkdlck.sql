
-- demo_fkdlck: demonstrate deadlock without FK index, and demo fat-index.

-- teste several cases: chk with single-field key and multi-field pk on chld

set echo off

drop table chd;
drop table par;

set echo on

create table par as  -- pick 10 records from userlist
select user_id id
     , username par_name
     from all_users where user_id <10 ; 

alter table par add constraint par_pk primary key ( id ) ;   

-- add one known record wihtout children
insert into par values ( -1, 'parent minus one, no chds' );

set echo off
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

create table chd as  -- add children to relevant parents
select o.object_id id
     , u.user_id   par_id
     , o.object_type chd_type, o.object_name  chd_name 
from all_objects o
   , all_users u
where u.username = o.owner
  and u.user_id < 10;

alter table chd add constraint chd_pk primary key ( id ) ; 
alter table chd add constraint chd_par_fk foreign key ( par_id ) references par ( id ) ;

-- now add to child-table, but dont commit, cause a lock.
insert into chd values ( -1, 0, 'new_type', 'chd minus one' ); 

set echo off
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- now, from separate transaction, mess with _any_ parent... 
declare
  pragma autonomous_transaction;
begin
  delete from par where id = -1  ;
  commit;
  end;
/

set echo off
prompt You just had a deadlock: parent-del needed lock on children
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- rollback self to clean up.
rollback ;

-- put index on
create index chd_par_fk on chd ( par_id ) ; 

-- re-add to child-table, cause "some lock" on chd again
insert into chd values ( -1, 0, 'new_type', 'chd minus one' ); 

set echo off
prompt You have an un-committed insert again, can someone delete a parent?
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- from separate transaction, delete the childless parent
declare
  pragma autonomous_transaction;
begin
  delete from par where id = -1  ;
  commit;
  end;
/

-- verify delete has worked
select id from par where id = -1 ; 

set echo off
prompt With index on fk, you could safely mess with parent
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- add the childless-parent (for demo-delete), and add a fat index
insert into par values ( -1, 'parent minus one, no chds' );
create index chd_par_fat_fk on chd ( par_id, chd_type ) ;
drop index chd_par_fk ;

-- insert into chd, cause "some lock" on chd again
insert into chd values ( -2, 0, '2ndnew_type', 'chd minus two' ); 

set echo off
prompt You have an un-committed insert again. Can someone delete a parent?
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- from separate transaction, delete the childless parent
declare
  pragma autonomous_transaction;
begin
  delete from par where id = -1  ;
  commit;
  end;
/

-- verify delete has worked
select id from par where id = -1 ; 

set echo off
prompt You were able to delete the parent, and no deadlocks...
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- rollback for cleanup.
rollback ; 


-- once more,  add the childless-parent (for demo-delete)
-- and remove th add a fat index, fk is no longer indexed
insert into par values ( -1, 'parent minus one, no chds' );
drop index chd_par_fat_fk ;

-- insert into chd, cause "some lock" on chd again
insert into chd values ( -2, 0, '2ndnew_type', 'chd minus two' ); 
set echo off

prompt Again, You have an un-committed insert, and FK is unindexes.. 
accept press_enter_to_continue  prompt "press enter to continue"
set echo on

-- from separate transaction, delete the childless parent
declare
  pragma autonomous_transaction;
begin
  delete from par where id = -1  ;
  commit;
  end;
/

-- verify parent still there..
select id from par where id = -1 ; 
