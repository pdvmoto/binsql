select 
  sys_context('USERENV', 'CON_ID') as con_id, 
  sys_context('USERENV', 'CON_NAME') as con_name 
from dual ;

drop table zz_test ;
create table zz_test ( id number not null primary key ) ;
alter table zz_test add  created_ts timestamp default systimestamp  ;
desc zz_test
 
/* 
**** commements here.. ****

batch : created, descriptiption, .. 
  status: NULL, Kan_gaan, Loopt, Gelopen, .. more..

batch_run : "result", history of batches. batch kan meerdere runs hebben, initial, fixes, catchup..
  fk: batch.
  info: start-stop-duur, nr_klanten, nr_docs, nr_errors, volume_bytes, nr_calls

klant:
  fk: batch.

klant_run: "result". Als batch een klant "doet" 
  fk: batch_run
  fk: klant
  info: nr_docs, start-stop-duur, volume, nr_calls ?

klant_doc :
  fk: klant (eventueel: batch)
  status: kan, loopt, OK, error, oldkey, newkey, hashes, last_batch
  => docs met status OK kunnen mee in controletelling.

klant_doc_run: conversion-historyk, de conversie van een doc, in een batchrun.
  fk: batch_run
  fk: doc.
  info: ok/error, oldkey, newkey, hash, size, timestamp, nr_calls

Process 1: batch_aanmaken:
  Vullen van tabellen B, K en K_D..

Process 2: initiele-Telling: 
tellen van klanten, docs, doc-types per batch en per klant.
gebruik: batch, klant, klant_doc
(dit houd o.a. in dat de klant_doc tabel ook "type info" moet bevatten)

Process 3:  batch_run
Conversie gaat in Batches, in stappen die we Batch_run noemen.
een batch-run is 
  poging tot conversie van Alle Docs in een Batch
  loop over alle klanten
    loop over alle klant_docus
      if docu = "kan gaaan" : converteer...
      converteer docu, schrijf result naar doc_run


Process 4: Controletelling

Process 5: Confrontatie v telligen


*/ 

/* */

drop table zz_test;
drop table zz_mig_document_run ;
drop table zz_mig_document ;

drop table zz_mig_doctype ; 

drop table zz_mig_klant_telling ;

drop table zz_mig_klant_run ;
drop table zz_mig_klant ;

drop table zz_mig_batch_run ;
drop table zz_mig_batch ;

/* */


Create table zz_mig_batch
(
  R_OBJECT_ID  VARCHAR2(16 CHAR)         NOT NULL
, created_dt   date                default SYSDATE
, created_by   varchar2(32)        default USER
, batch_volgorde number (6,0)      not null -- sneaky, volgorde Moet, nog beter: sequence ?
, batch_naam   varchar2(32)        not null
, batch_status varchar2(32)        not null 
, start_run    date
, end_run      date
, versie_config varchar2(32)
, log_file     varchar2(255) -- or pointer to file-object ?
, workspace_uuid     varchar2(36)  -- RAW-16 would be more approprate..
, counter_records    number ( 9,0)
, counter_api_calls   number ( 9,0)
, more_info           varchar2(4000)
);

alter table zz_mig_batch add constraint zz_mig_batch_pk primary key ( r_object_id ) ;

prompt " - - - " BATCH table done

Create table zz_mig_batch_run
( R_OBJECT_ID         VARCHAR2(16 CHAR)         NOT NULL
, batch_id            varchar2(16 )          not null -- fk to batch waar
, created_dt          date       default SYSDATE
, run_status          varchar2(32) default 'CREATED' 
, nr_klanten          number ( 6,0)
, nr_docs             number ( 9,0)
, log_file            varchar2(255) -- or pointer to file-object ?
, counter_records     number ( 9,0)
, counter_api_calls   number ( 9,0)
, more_info           varchar2(4000)
);

alter table zz_mig_batch_run add constraint zz_mig_batch_run_pk       primary key ( r_object_id ) ;
alter table zz_mig_batch_run add constraint zz_mig_batch_run_fk_batch foreign key (    batch_id ) references zz_mig_batch ( r_object_id ) ;

prompt " - - - "  BATCH_RUN done


Create table zz_mig_klant
( R_OBJECT_ID         VARCHAR2(16 CHAR)         NOT NULL
, batch_id            varchar2(16 )          not null -- fk to batch waar
, created_dt             date       default SYSDATE
, Klant_r_object_id  varchar2(16)  not null -- fk to klant, niet hard definieren..
, Klant_uuid  varchar2(36)  --  nieuwe ID in CCM, RAW-16 would be more approprate
, Start_conv timestamp               --(millisec)
, End_conf      timestamp              -- (millisec)
, Result_status varchar2(32) -- Set LoV constraint.
, sha256_old           varchar2(256)
, sha256_new          varchar2(256)
, Counter_documents         number ( 9,0)
, Counter_API_Calls_done number (9,0 )
);

alter table zz_mig_klant add constraint zz_mig_klant_pk       primary key ( r_object_id ) ;
alter table zz_mig_klant add constraint zz_mig_klant_fk_batch foreign key ( batch_id ) references zz_mig_batch ( r_object_id ) ;

-- Unique Key: (batch_id + klant_id ) klant unique inside Batch  and create relation to document
alter table zz_mig_klant  add constraint zz_mig_klant_uk unique ( batch_id, klant_r_object_id ) ;
--create unique index zz_mig_klant_uk on zz_mig_klant ( batch_id, klant_r_object_id ) ;

prompt " - - - " KLANT table done

Create table zz_mig_klant_run
( R_OBJECT_ID         VARCHAR2(16 CHAR)         NOT NULL
, created_dt             date       default SYSDATE
, Klant_id  varchar2(16)  not null -- fk to klant, niet hard definieren..
, batch_run_id          varchar2(16 )          not null -- fk to batch waar
, Klant_uuid  varchar2(36)  --  nieuwe ID in CCM, RAW-16 would be more approprate
, Start_conv timestamp               --(millisec)
); 

-- kl_run is descendent of kl, so fk to kl, and thus  descendent of batch..
-- kl_run is descendent of batch_run..
-- kl can only run once in a batch_run : uk = kl + b_run..

alter table zz_mig_klant_run add constraint zz_mig_klant_run_pk primary key ( r_object_id ) ;

alter table zz_mig_klant_run add constraint zz_mig_klant_run_fk_batch_run foreign key ( batch_run_id ) references zz_mig_batch_run ( r_object_id ) ;
alter table zz_mig_klant_run add constraint zz_mig_klant_run_fk_klant     foreign key ( klant_id     ) references zz_mig_klant     ( r_object_id ) ;

alter table zz_mig_klant_run add constraint zz_mig_klant_run_uk unique ( batch_run_id, klant_id ) ;

prompt " - - - " KLANT_RUN done

-- and details per klant, approx like this:
Create table zz_mig_document
( R_OBJECT_ID   VARCHAR2(16 CHAR)         NOT NULL
, created_dt    date                  default SYSDATE
, Klant_id      varchar2(16)          not null -- fk to mig_klant, vastleggen
, document_id   varchar2(16)          not null -- fk to document (niet hard definieren?)
, doc_type      varchar2(32)          not null -- FK
, doc_acl       varchar2(32)          not null -- FK
, start_conv    timestamp
, end_conv      timestamp
, result_status varchar2(32)          -- LoV : Ready_to_go, In_Process, OK, Warning, Error, ...
, sha256_old    varchar2(256)
, sha256_new    varchar2(256)
, STATUS                   VARCHAR2(255 BYTE),
  DETAILS                  VARCHAR2(255 BYTE),
  ROOT_NAME                VARCHAR2(255 BYTE),
  ROOT_DISPLAY_NAME        VARCHAR2(255 BYTE),
  WORKSPACE_TYPE           VARCHAR2(255 BYTE),
  WORKSPACE_TEMPLATE_NAME  VARCHAR2(255 BYTE),
  WORKSPACE_INSTANCE_NAME  VARCHAR2(255 BYTE),
  DESCRIPTION              VARCHAR2(255 BYTE),
  OBJECT_NAME              VARCHAR2(255 BYTE),
  TYPE                     VARCHAR2(255 BYTE),
  VERSION_LABEL            VARCHAR2(255 BYTE),
  FOLDER_PATH              VARCHAR2(255 BYTE),
  TEMPLATE_FOLDER_PATH     VARCHAR2(255 BYTE),
  PRIMARY_FILENAME         VARCHAR2(255 BYTE),
  CREATE_VIEWER_RENDITION  VARCHAR2(255 BYTE),
  CC_OBJECT_ID             VARCHAR2(255 BYTE)
);
 
-- kl_doc refers to kl, and thus to batch..
-- doc is unique in this table, only 1 conversion.
-- other FKs: later...

alter table zz_mig_document add constraint zz_mig_document_pk        primary key ( r_object_id ) ;

alter table zz_mig_document add constraint zz_mig_document_fk_klant  foreign key ( klant_id    ) references zz_mig_klant     ( r_object_id ) ;

alter table zz_mig_document add constraint zz_mig_document_uk unique ( document_id ) ;

prompt " - - - " DOCUMENT done 

Create table zz_mig_document_run
( R_OBJECT_ID         VARCHAR2(16 CHAR)         NOT NULL
, created_dt          date       default SYSDATE
, document_id         varchar2(16)  not null -- fk to klant, niet hard definieren..
, batch_run_id          varchar2(16 )          not null -- fk to batch waar
, doc_uuid  varchar2(36)  --  nieuwe ID in CCM, RAW-16 would be more approprate
, Start_conv timestamp               --(millisec)
);

-- doc_run is descendent of doc, so fk to doc, and thus  descendent of kl and of batch..
-- doc_run is descendent of batch_run..
-- doc can only run once in a batch_run : uk = doc_id + b_run..

alter table zz_mig_document_run add constraint zz_mig_document_run_pk primary key ( r_object_id ) ;

alter table zz_mig_document_run add constraint zz_mig_document_run_fk_batch_run foreign key ( batch_run_id ) references zz_mig_batch_run ( r_object_id ) ;
alter table zz_mig_document_run add constraint zz_mig_document_run_fk_doc       foreign key ( document_id  ) references zz_mig_document  ( r_object_id ) ;

alter table zz_mig_document_run add constraint zz_mig_doocument_run_uk unique ( batch_run_id, document_id ) ;

prompt " - - - " DOCUMENT_RUN done 
prompt .


create table zz_mig_doctype 
( r_object_id       varchar2(16) not null
, doc_type          varchar2(32) not null
, doc_type_desc     varchar2(128) not null
);

alter table zz_mig_doctype add constraint zz_mig_doctype_pk primary key ( r_object_id ) ;
alter table zz_mig_doctype add constraint zz_mig_doctype_uk unique      (    doc_type ) ;

-- limit the values in doc_type
alter table zz_mig_document add constraint zz_mig_document_fk_type foreign key ( doc_type ) references zz_mig_doctype ( doc_type ) ;

prompt " - - - " DOCTYPE done 
prompt .

/* Tellingen... generic datamodel voor tellingen per klant
note : geen Batch_id,
want 1. klant zit in Batch..
en 2. tellingen worden met SQL or API gevuld, los van batches..

*/
Create table zz_mig_klant_telling
( R_OBJECT_ID           VARCHAR2(16 CHAR) NOT NULL
, created_dt            date              default SYSDATE
, created_by            varchar2(32)      not null
, Klant_id              varchar2(16)      not null -- fk to mig_klant, vastleggen
, telling_type          varchar2 (32)     not null -- fk naar definitie van telling...liefst in CAPS
, telling_uitkomst      number ( 9,0)
);

alter table zz_mig_klant_telling add constraint zz_mig_klant_telling_pk primary key ( r_object_id );
alter table zz_mig_klant_telling add constraint zz_mig_klant_telling_uk unique      ( klant_id, telling_type );

alter table zz_mig_klant_telling add (
constraint  zz_mig_klant_telling_fk_klant
  foreign key             (klant_id)
  references zz_mig_klant (r_object_id)
  );

-- consider FT to telling, link to "definition


/* vragen over telling:
 - bronnen zijn: documentum en CCM.
 - bij deze definitie: is telling-uit-documentum een andere telling dan telling-uit-ccm: andere definties.. wel vergelijkbaar.
 - zodoende geen update nodig, beide bronnen kunnen "inserts" doen (en daarmee created_date vastleggen)

*/

prompt " - - - " KLANT_TELLING done 
prompt .

prompt .
prompt demo inserts...
prompt .

set echo on

insert into zz_mig_batch
( r_object_id, created_by, batch_volgorde, batch_naam, batch_status )
values
( '0123456789ABCDEF', 'Testing_pdv', 0, 'Eerste batch', 'CAN GO' );

-- delete from zz_mig_klant ;
insert into zz_mig_klant ( r_object_id, batch_id, klant_r_object_id )
                    select r_object_id, '0123456789ABCDEF', r_object_id
from dis_klant_s
where (woonplaats like 'GOES%'
   or woonplaats like 'MIDDEL%') ;

insert into zz_mig_document ( r_object_id, batch_id,  klant_r_object_id, document_id, result_status )
select s.r_object_id, '0123456789ABCDEF', k.r_object_id, s.r_object_id, 'CAN GO'
from dis_document_s s
   , dis_klant_s k
where k.relatienummer = s.relatienummer
and k.relatienummer > 0
and k.r_object_id in ( select klant_r_object_id from zz_mig_klant where batch_id = '0123456789ABCDEF') ;

commit ;

/* old stuff

alter table zz_mig_klant_document add (
constraint  zz_mig_klant_docu_fk_klant
  foreign key             (batch_id, klant_r_object_id)
  references zz_mig_klant (batch_id, klant_r_object_id)
  );
 
alter  

alter table zz_mig_klant_document add (
  constraint zz_mig_klant_document_fk_klanT
  foreign key
  (batch_id, klant_r_object_id )
references zz_mig_klant ( batch_id, klant_r_object_id )
);

*/ 

/*

drop table zz_test;
drop table zz_mig_klant_document_run ;
drop table zz_mig_klant_document

drop table zz_mig_klant_run ;
drop table zz_mig_klant ;

drop table zz_mig_batch_run ;
drop table zz_mig_batch ;

drop table ZZ_TEST ;

drop function UUID7;
drop function FMT_UUID ;
drop function UUID7_TS ;
drop function UUID_GET_VERSION ;
drop function VC_TO_UUID ;
drop function UUID7_EPOCH ;

*/

