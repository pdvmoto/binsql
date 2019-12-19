
-- to modify defaults:
--  execute statspack.modify_statspack_parameter (i_snap_level=>7);

execute perfstat.statspack.snap ( i_ucomment => 'my snapshot' );   

     