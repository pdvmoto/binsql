
/* 
The Query to find FK's with missing index 
can be constructed by comparing constraint_columns
to index_columns like this 
(original courtesy of orasnap):
*/

column owner format A15
column table_name format A20
column constraint_name format a20
column column_name format a20
column position format 999 head pos


select   acc.OWNER,
	   acc.table_name,
         acc.CONSTRAINT_NAME,
         acc.COLUMN_NAME,
         acc.POSITION
from     dba_cons_columns acc, dba_constraints ac
where    ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
and      ac.owner           = acc.owner
and      ac.CONSTRAINT_TYPE = 'R'
and      acc.OWNER not in ('SYS','SYSTEM')
and      not exists (
            select   'TRUE'
            from     dba_ind_columns b
            where    b.TABLE_OWNER     = acc.OWNER
            and      b.TABLE_NAME      = acc.TABLE_NAME
            and      b.COLUMN_NAME     = acc.COLUMN_NAME
            and      b.COLUMN_POSITION = acc.POSITION)
order by acc.OWNER, acc.CONSTRAINT_NAME, acc.position, acc.COLUMN_NAME
/



