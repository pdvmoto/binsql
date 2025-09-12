
-- Just an EXAMPLE...

CREATE PLUGGABLE DATABASE ORCL     
  ADMIN USER pdbadmin IDENTIFIED BY oracle
  file_name_convert=('/opt/oracle/oradata/FREE/pdbseed', '/opt/oracle/oradata/FREE/freepdb1')
  STORAGE ( MAXSIZE UNLIMITED MAX_SHARED_TEMP_SIZE UNLIMITED);

CREATE PLUGGABLE DATABASE ORCL     
  ADMIN USER pdbadmin IDENTIFIED BY oracle
  file_name_convert=('/opt/oracle/oradata/ORCLCDB/pdbseed', '/opt/oracle/oradata/ORCLCDB/orcl')
  STORAGE ( MAXSIZE UNLIMITED MAX_SHARED_TEMP_SIZE UNLIMITED);

alter pluggable database ORCL     open;

alter pluggable database ORCL     save state ;

show pdbs

alter session set container=orcl ;

create user scott identified by tiger ;
grant connect, resource, dba to scott ;
grant advisor_role to scott ;
grant execute on dbms_lock to scott ; 

