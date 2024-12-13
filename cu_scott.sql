
connect / as sysdba

alter session set container=freepdb1 ; 

create user scott identified by tiger ;

grant connect, resource, dba to scott ; 

