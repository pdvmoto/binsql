
select count (*) from dba_obj_audit_opts
/


select * from dba_stmt_audit_opts
union
select * from dba_priv_audit_opts
/
