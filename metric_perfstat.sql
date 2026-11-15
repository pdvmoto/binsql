
WITH snap_data AS
(
    SELECT
        sn.dbid,
        sn.instance_number,
        sn.startup_time,
        sn.snap_id,
        sn.snap_time,

        tm.value AS db_time_us,

        ss.value AS nr_connections

    FROM stats$snapshot sn

    JOIN stats$sys_time_model tm
      ON tm.snap_id         = sn.snap_id
     AND tm.dbid            = sn.dbid
     AND tm.instance_number = sn.instance_number

    JOIN stats$time_model_statname tn
      ON tn.stat_id = tm.stat_id
     AND tn.stat_name = 'DB time'

    JOIN stats$sysstat ss
      ON ss.snap_id         = sn.snap_id
     AND ss.dbid            = sn.dbid
     AND ss.instance_number = sn.instance_number
     AND ss.name            = 'logons current'
),
snap_delta AS
(
    SELECT
        dbid,
        instance_number,
        startup_time,

        LAG(snap_id) OVER
            (PARTITION BY dbid, instance_number, startup_time
             ORDER BY snap_id) AS start_snap_id,

        snap_id AS end_snap_id,
        snap_time AS snap_end_time,

        nr_connections,

        db_time_us -
            LAG(db_time_us) OVER
                (PARTITION BY dbid, instance_number, startup_time
                 ORDER BY snap_id) AS db_time_delta_us,

        (snap_time -
            LAG(snap_time) OVER
                (PARTITION BY dbid, instance_number, startup_time
                 ORDER BY snap_id)
        ) * 86400 AS elapsed_seconds

    FROM snap_data
)
SELECT
    start_snap_id,
    end_snap_id,
    snap_end_time,
    nr_connections,

    ROUND(db_time_delta_us / 1000000, 2)
        AS db_time_seconds,

    ROUND(
        (db_time_delta_us / 1000000) /
        NULLIF(elapsed_seconds, 0),
        3
    ) AS average_active_sessions

FROM snap_delta
WHERE start_snap_id IS NOT NULL
  AND elapsed_seconds > 0

ORDER BY end_snap_id;

