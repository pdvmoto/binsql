
rem put breadcrum table ...

create table hck_ing ( id number generated always as identity primary key
, crea_dt date default sysdate
, payload varchar2(256) ) ;

insert into hck_ing ( payload ) values ( 'hck: initializing' );


