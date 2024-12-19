--
-- demo_enum_bug.sql: not sure if this is bug, or just funny error message.
--
-- best run in SQL*Plus for more concise error messaages.
--


drop domain color_enum ;

--
-- now re-create domains,
-- and one of them could be 3999 long..
--

set echo on

create domain color_enum  as
enum (
  red,
  orange,
  yellow,
  green,
  blue,
  indigo,
  violet
);

create table tcolors ( 
  id number
, color color_enum
);

--
-- verify objects
--

select name from user_domains ;

desc tcolors 

insert into tcolors values ( 16, color_enum.purple );

insert into tcolors values ( 17, 17 ) ;

-- 
-- The first error, column not allowed, is a bit confusing.
-- Probably bcse it interprets the domain.constant as "column expression".
--
-- The second error is more clear: 
-- it refers to a Check-constraint and mentions the domain.
-- 
