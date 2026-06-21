/* 
tst_demo.sql : need a demo table with ID, date, float, vc2, clob..

*/

drop table    tst_demo ;
drop sequence tst_demo_seq ;

create sequence tst_demo_seq ;

create table    tst_demo    (
  id  number(10,0) generated always as identity
, created_dt    date default sysdate
, some_ts       timestamp             -- special case for TS
, amount        number                -- some floating point value
, fraction      number                -- even funnier float, try 2.7E1.
, descr         varchar2(64 char)     -- use this for some text
, long_text     varchar2(1024 char)   -- try longer text, with CR/LF
, memo          clob                  -- put serious text here..
);

-- now put some stuff in..
insert into tst_demo ( amount, fraction, descr )
select level/3, level/10, 'Voilà! The café serves crème brûlée.' 
from dual connect by level < 2 ;

insert into tst_demo ( amount, fraction, descr )
select level/4, level/5, 'A naïve fiancé ordered piñata décor.' 
from dual connect by level < 2 ;

insert into tst_demo ( amount, fraction, descr )
select level*104, level*10.7, 'test quotes here [ " ] [ '' ] ' 
from dual connect by level < 2 ;

insert into tst_demo ( amount, fraction, descr )
select level*1024, level/1024, 'Зојина сарадња је спасила суфле.'
from dual connect by level < 2 ;

-- now test some memo-style fields..
insert into tst_demo ( amount, fraction, descr, long_text )
select level*104, level*10.7, 'test double quotes here [ " ] ' 
, q'{ some multi_line
line 1: A naïve fiancé ordered piñata décor. 
line 2: Зојина сарадња је спасила суфле.
line 3: and a single [ ' ] + double quote [ " ]
}' 
from dual connect by level < 2 ;


select id, created_dt, amount, fraction, descr from tst_demo 
order by 1 ;

select id, created_dt, amount, fraction, long_text from tst_demo 
where long_text is not null
order by 1 ;

commit ;

