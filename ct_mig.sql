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
drop table zz_mig_klant_document ;
drop table zz_mig_klant ;
drop table zz_mig_batch ;

/* */


Create table zz_mig_batch
(
  R_OBJECT_ID  VARCHAR2(16 CHAR)         NOT NULL
, created_dt   date                default SYSDATE
, created_by   varchar2(32)        default USER
, batch_volgorde number (6,0)      not null -- sneaky, volgorde Moet, nog beter: sequence ?
, batch_naam   varchar2(32)        not null
, start_run    date
, end_run      date
, versie_config varchar2(32)
, log_file     varchar2(255) -- or pointer to file-object ?
, workspace_uuid     varchar2(36)  -- RAW-16 would be more approprate..
, counter_records    number ( 9,0)
, counter_api_calls   number ( 9,0)
);

alter table zz_mig_batch add constraint zz_mig_batch_pk primary key ( r_object_id ) ;

prompt batch table done

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


alter table zz_mig_klant add constraint zz_mig_klant_pk primary key ( r_object_id ) ;
alter table zz_mig_klant add constraint zz_mig_klant_fk_batch foreign key ( batch_id ) references zz_mig_batch ( r_object_id ) ;

-- Unique Key: (batch_id + klant_id ) klant unique inside Batch  and create relation to document
alter table zz_mig_klant  add constraint zz_mig_klant_uk unique ( batch_id, klant_r_object_id ) ;
--create unique index zz_mig_klant_uk on zz_mig_klant ( batch_id, klant_r_object_id ) ;

prompt klant table done

 

-- and details per klant, approx like this:
Create table zz_mig_klant_document
( R_OBJECT_ID        VARCHAR2(16 CHAR)         NOT NULL
, Batch_id     varchar2(16 )                 -- fk to batch waar
, created_dt             date              default SYSDATE
, Klant_r_object_id  varchar2(16)  -- fk to mig_klant, vastleggen
, document_id   varchar2(16)          -- fk to document (niet hard definieren?)
, start_conv    timestamp
, end_conv      timestamp
, result_status varchar2(32)          -- LoV : Ready_to_go, In_Process, OK, Warning, Error, ...
, sha256_old    varchar2(256)
, sha256_new    varchar2(256)
);
 

alter table zz_mig_klant_document add constraint zz_mig_klant_document_pk primary key ( r_object_id ) ;

-- alter table zz_mig_klant          add constraint zz_mig_klant_doc_fk_klant foreign key ( batch_id, klant_r_object_id )
-- references zz_mig_klant ( batch_id, klant_r_object_id ) ;


alter table zz_mig_klant_document add (
constraint  zz_mig_klant_docu_fk_klant
  foreign key             (batch_id, klant_r_object_id)
  references zz_mig_klant (batch_id, klant_r_object_id)
  );
 

alter table zz_mig_klant_document add (
  constraint zz_mig_klant_document_fk_klanT
  foreign key
  (batch_id, klant_r_object_id )
references zz_mig_klant ( batch_id, klant_r_object_id )
);


/*

drop table zz_test;
drop table zz_mig_klant_document ;
drop table zz_mig_klant ;
drop table zz_mig_batch ;
drop table zz_mig_klant_document ;

drop table ZZ_MIG_KLANT ;
drop table ZZ_MIG_BATCH ;
drop table ZZ_TEST ;

drop function UUID7;
drop function FMT_UUID ;
drop function UUID7_TS ;
drop function UUID_GET_VERSION ;
drop function VC_TO_UUID ;
drop function UUID7_EPOCH ;

*/
