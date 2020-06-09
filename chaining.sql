select 'ANALYZE TABLE '||owner||'.'||table_name||' LIST CHAINED ROWS;'
from all_tables
where owner = '&&1'
/
