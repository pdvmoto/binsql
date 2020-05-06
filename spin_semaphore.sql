
/*** 

spin_semaphore: measure overhead of checking nr-session (for module=:param)

todo:
 - need a spin-call to call proc for n-seconds to measure overhead (in : seconds)
 - need emtpy procedure to show 0-load (in/out: ...)
 - need procedure with check to measure actual load - 1st, to build + prove concept
    in: module_name, nr-sessions (default=1, exclusive ?)

notes:
 - return json messages:  select json_object ( key 'errmsg' value 'this message'  ) from dual ; 

*/

set serveroutput on 

-- first a separate function

create or replace function f_get_nr_sess ( pvc_mod_name IN varchar2 default null )
return number
is
  n_nr_sess number ;
begin

  -- null;
  -- dbms_output.put_line ( 'chk_sema: get_nr_sessions for : [' || pvc_mod_name || ']');

  select count(*) into n_nr_sess
  from sys.v_$session s
  where module || '-' =  pvc_mod_name || '-' ;

  return n_nr_sess ;

end ; -- get_nr_sess
/

-- now a package..
create or replace package chk_sema
as

function get_nr_sess ( pvc_mod_name IN varchar2 )
return number;

-- a procedure that uses count-v-dollar to find nr of siblings
procedure chk_sema_vdolses ( 
  pn_nr_sess   IN number   default 1            /* why 1 ? exclusive ! */
, pvc_mod_name IN varchar2  default null        /* null = total sessions */ 
, pvc_errmsg   OUT varchar2 
) ;


end chk_sema;
/

show errors 


create or replace package body chk_sema
as

function get_nr_sess ( pvc_mod_name IN varchar2 ) 
return number 
is
  n_nr_sess number ;
begin

  -- null;
  -- dbms_output.put_line ( 'chk_sema: get_nr_sessions for : [' || pvc_mod_name || ']');  

  select count(*) into n_nr_sess
  from sys.v_$session s
  where module || '-' =  pvc_mod_name || '-' ; 

  return n_nr_sess ;

end ; -- get_nr_sess 


-- using v-dol
procedure chk_sema_vdolses ( 
  pn_nr_sess   IN number    default 1  /* why 1 ? exclusive ! */
, pvc_mod_name IN varchar2  default null  
, pvc_errmsg   OUT varchar2 
)
is
  n_nr_sess number := 0 ; 
  vc_errmsg varchar2(32) := 'no error' ;
begin
  null;

  dbms_application_info.set_module ( 
        module_name => pvc_mod_name, action_name => pvc_mod_name );
  
  DBMS_LOCK.SLEEP( 2 ); 

  -- dbms_application_info.set_module ( module_name => '', action_name => '' );

  n_nr_sess := get_nr_sess ( pvc_mod_name ) ;
  dbms_output.put_line ( 'chk_sema: nr sessions found: ' || n_nr_sess ); 

  pvc_errmsg := vc_errmsg ; 

end ; -- chk_sema_vdolses 

end chk_sema ;
/

show errors 


-- do a test-call..

prompt diagnose call...

variable errmsg varchar2(32);

set timing on

exec chk_sema.chk_sema_vdolses ( pvc_mod_name => 'Check_nr_sess' , pvc_errmsg => :errmsg ); 
exec chk_sema.chk_sema_vdolses ( pvc_mod_name => null , pvc_errmsg => :errmsg ); 

set timing off

select :errmsg from dual ;
