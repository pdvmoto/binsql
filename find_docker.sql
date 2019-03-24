select machine, sql_id, count (*) from
v$session where sql_id in ( '1utwsqjtwqfxr' , 'fmjcya74wwn8x'
, 'g59s8dj44w454'
--, '1qd1c0nkyu9y7', 'g59s8dj44w454', 'cfnjcz8ydr882'
)
group by machine, sql_id
/
