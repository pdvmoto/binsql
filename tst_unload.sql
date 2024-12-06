--
-- tst_unload: testing unload of a VECTOR from sqlcl
--
-- usage: 
--      - put vector data in table first via SQL> @ini_unload.sql
--      - run this file to test unload + load of data
--
-- description:
-- loading of large strings is problematic.
-- in one version of sqlcl, the concatenation of clobs, using 
--   ... to_clob () || to_clob ... seems to fix this.
-- this file does the very quick test- and demo run.
-- 
--

-- where are we..
prompt "."

show version

prompt "."
prompt "Take note of the version of SQLcl."
prompt "."
prompt "If needed, create table with 9 rec, from ini_unload.sql."
prompt "..."
accept  hit_enter

-- show the table
desc tst_unload

-- show some similar vectors..
set echo on

select v1.id id1
     , v2.id id2
    , 1 - (v1.vect <=> v2.vect) as cos_similar
from tst_unload v1
   , tst_unload v2
where v1.id < v2.id
  and 1 - (v1.vect <=> v2.vect) > 0.7
order by 3 desc ;

set echo off

prompt "."
prompt "Take note of the cos-similarity between 3 vectors."
prompt "..."
accept  hit_enter

-- now unload it as inserts

set loadformat insert

unload tst_unload

-- delete from tst_unload, or better, just drop it...
drop table tst_unload ; 
create table tst_unload ( id number, vect vector ( 2048, float64) );

prompt "."
prompt "data unloaded, table dropped.. now try reload"
prompt "..."
accept  hit_enter

@TST_UNLOAD_DATA_TABLE
commit ; 

-- re-show same,  similar vectors..
select v1.id id1
     , v2.id id2
    , 1 - (v1.vect <=> v2.vect) as cos_similar
from tst_unload v1
   , tst_unload v2
where v1.id < v2.id
  and 1 - (v1.vect <=> v2.vect) > 0.7
order by 3 desc ;

-- This looks like proof: 
-- cos-similarity will be same if the unload + re-insert worked..
--

prompt "."
prompt "Reloading didnt work anymore when unload was done with:
prompt "SQLcl: Release 24.3.2.0 Production Build: 24.3.2.330.1718"
prompt "..."
accept  hit_enter

prompt "."
prompt "End of tst_unload.sql "
prompt "."

