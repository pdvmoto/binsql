

Audit system audit;

noAudit all on sys.aud$ by access;

--Audit all on sys.audit$ by access;
--Audit all on sys.audbkp1 by access;
--Audit all on sys.audbkp2 by access;
--Audit all on sys.audbkp3 by access;

Audit session;
Audit system grant;

audit role;

audit alter system;
audit alter database;
audit tablespace;
audit rollback segment;
audit public database link;
audit public synonym;
audit user;
audit index;
audit procedure;
audit cluster;
audit sequence;
audit synonym;
audit table;
audit trigger;
audit view;
audit alter table;
audit grant procedure;
audit grant sequence;
audit grant table;
audit alter sequence;

noaudit delete any table;
noaudit insert any table;
noaudit update any table;
noaudit select any table;

audit alter any table;
audit drop any table;

noaudit lock any table;

audit alter any procedure;
audit drop any procedure;

noaudit execute any procedure;

audit alter any trigger;
audit drop any trigger;

--audit insert table by (DBA id) by session;
--audit update table by (DBA id) by session;
--audit delete table by (DBA id) by session;
--audit select table by (DBA id) by session;

audit profile ;
