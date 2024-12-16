
-- demo_fk: par, chd, lkp : lookup. optinal FK on chd

drop table chd ; 
drop table par ; 
drop table lkp ; 

-- Create the 'par' table
CREATE TABLE par (
  id          NUMBER        PRIMARY KEY 
, descr       VARCHAR2(255)
);

-- Create the 'lkp' table
CREATE TABLE lkp (
  id          NUMBER        PRIMARY KEY
, descr       VARCHAR2(255) 
);

-- Create the 'chd' table with foreign keys
CREATE TABLE chd (
  id          NUMBER        PRIMARY KEY        
, par_id      NUMBER        DEFAULT 0   NOT NULL 
, lkp_id      NUMBER                    -- FK can be NULL <------  demo
, descr       VARCHAR2(255)    
, CONSTRAINT fk_chd_par FOREIGN KEY (par_id) REFERENCES par (id)
, CONSTRAINT fk_chd_lkp FOREIGN KEY (lkp_id) REFERENCES lkp (id)
);

insert into par ( id, descr ) values ( 0, 'parent N/A, dlft 0' );
insert into par ( id, descr ) values ( 1, 'first parent' );
insert into par ( id, descr ) values ( 2, 'second parent' );

insert into lkp ( id, descr ) values ( 0, 'N/A - in case null or 0' );
insert into lkp ( id, descr ) values ( 1, 'lookup1' );
insert into lkp ( id, descr ) values ( 2, 'lookup2' );
insert into lkp ( id, descr ) values ( 3, 'lookup3' );


-- demo: insert without the par or lkp: values will dflt to 0 and null
insert into chd ( id, descr ) 
         values (  1, 'desc of with dflt par and null-lookup') ; 

-- demo insert withoug lkp_id, but 
insert into chd ( id, par_id, descr ) 
         values (  2,      1, 'chk with par_id=1, null-lookup') ; 

-- insert lkp, but no parent 
insert into chd ( id, lkp_id, descr ) 
         values (  3,      1, 'chk with dlft par, and lookup1') ; 

-- insert complete set
insert into chd ( id, par_id, lkp_id, descr ) 
         values (  4,      2,      3, 'chk with par and lookup3') ; 

column id format 9999
column par_id format 9999 
column lkp_id format 9999 
column parent_descr format A20
column lookup_descr format A20

select c.id  
     , c.par_id
     , p.descr                      parent_descr
     , c.lkp_id
     , nvl ( l.descr , '-lkp_id is null-' )   lookup_descr
from chd c, par p, lkp l
where c.par_id = p.id
  and c.lkp_id = l.id (+) 
order by id ; 
commit ; 

