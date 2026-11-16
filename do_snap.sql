
-- to modify defaults:
-- execute statspack.modify_statspack_parameter (i_snap_level=>7);

execute statspack.snap(i_snap_level => 7);

-- or add a comment to your snapshot.
-- execute perfstat.statspack.snap ( i_ucomment => 'my snapshot' );   

     
