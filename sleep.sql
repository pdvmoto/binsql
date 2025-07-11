
doc
	sleep.sql : sleep for n secs
#

exec sys.dbms_lock.sleep ( &1 ) ;
