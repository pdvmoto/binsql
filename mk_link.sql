
doc

	mk_link.sql : create a database link, called l_remote

#

SELECT 'You are : ' || USER  || ' @ ' || global_name    current_user 
FROM global_name;

SELECT 'Please enter connect-data for the user to compare with:'
FROM global_name;

accept remote_user      char prompt  'Remote user : ' ; 
accept passwd           char prompt  'Remote Password : ' ; 
accept remote_db        char prompt  'Remote Database : ' ;

drop database link l_remote;

CREATE DATABASE LINK l_remote
	CONNECT TO &remote_user 
	IDENTIFIED BY &passwd USING '&remote_db' ;

set arraysize 1
set maxdata 20000


/** old code
create public database link dbl_dev
        connect to scott identified by tiger
        using 'APPDEV' ;

-- note : APPDEV needs to have a tns-entry

/***
create public database link dbl_dev2
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 10.4.99.3)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = ORCL)))
***/
~                                                                                                 
~                             
SELECT  gn.global_name			current_server
FROM    global_name     		gn ;
	
SELECT  gn.global_name			linked_server
FROM    global_name@l_remote    	gn ;

