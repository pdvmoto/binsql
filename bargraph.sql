
/*
bargraph :
 - use max-over() to grab max-value of series
 - use RPAD to draw graph. 
*/

column bar_2pct format A51 
column val format 999,999
column dt format A15
column id format 999,999

select id
, to_char ( end_dt, 'DY HH24:MI') dt
, round ( val)  val
--, max (val) over () as max  -- lazy way to find max
--, 20 * val / (max(val) over () ) as n_20th
, rpad ( ' ', 50 * val / (max(val) over () ), '*'  )as bar_2pct
from m_values ; 

