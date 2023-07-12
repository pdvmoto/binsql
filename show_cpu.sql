
column num_cpu format 999  
column num_cpu_cores format 999   head cpu_cores
column num_cpu_sockets format 999  head cpu_sockets

select cpu_count_current    num_cpu
, cpu_core_count_current    num_cpu_cores
, cpu_socket_count_current  num_cpu_sockets
from v$license ; 

