
create or replace function f_delay ( nsec number default 1 ) return number as 
begin
  dbms_session.sleep ( trunc ( nsec) );
  return trunc ( nsec ) ;
end ;
/
show errors 

