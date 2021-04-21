
select 'rm ' || name 
from v$datafile
/


select 'rm ' || member
from v$logfile
/

select 'rm ' || name 
from v$controlfile
/

