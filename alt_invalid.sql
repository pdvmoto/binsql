
doc
	alt_invalid.sql : prepare compile statements for invalid objs.
#

/***SELECT
  2   object_name  c0
  3  , '0'    c0
  4  ,  ' alter session set current_schema="' || OWNER || '";'
  5  FROM  sys.dba_objects
  6  WHERE  status = 'INVALID'
  7   UNION
***/

SELECT
--   object_name  c0
--  , '0'    c0
    'alter '
  ||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)
  ||' '
  ||owner
  ||'."'
  ||object_name
  ||'" compile '
  || decode(object_type,'PACKAGE BODY',' BODY ; ', ' ;' )
  FROM  sys.dba_objects
  WHERE  status = 'INVALID'
  -- order by 1, 2
/

