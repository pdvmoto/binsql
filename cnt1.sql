
/** 
find un-needed indexes, start with counting..

PCS	PIL_TRANSIT_DECLARATIONS
PCS	PIL_EQUIPMENTS
PCS	PIL_CONSIGNMENTS
PCS	MMT_MESSAGE_TRACKING_LOGS
PCS	PIL_BARGE_CARGO_SUBCARRIAGES
PCS	MSG_MSG_SCH_ITEM_CONCRETES
PCS	PIL_DG_GOODS_ITEMS
PCS	PIL_VIP_PRODUCT_DECLARATIONS
PCS	MSG_MESSAGE_SCHEME_ITEM_TMPLTS
PCS	PIL_CONSIGNMENT_ADOPTIONS
PCS	PIL_VISIT

****/

column owner format A20
column table_name format A30
column ind_count format 999 head idxes
column num_rows format 999,999,999 head num_rows

-- find most indexes tables, and rowcounts

with ind_cnt as 
( select owner, table_name, count (*) ind_count
from dba_indexes 
where owner not like 'SYS%'
and owner not like 'XDB%'
group by owner, table_name
)
select i.owner, i.table_name, i.ind_count , t.num_rows 
from 
  dba_tables t
, ind_cnt i
where t.owner = i.owner
  and t.table_name = i.table_name
order by 3 ; 
