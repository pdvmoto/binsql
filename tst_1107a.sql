
/**** 
-- pick any of these |CSM_ID to test
select * from (
select cadv.id, cad.csm_id, cadv.ogn_id, cadv.adoption_start_date
from pcs.pil_consignment_adoptions_v cadv
   , pcs.pil_consignment_adoptions cad
where cad.id = cadv.id
order by cad.id desc ) t
where rownum < 20;

****/

spool fix_1107

Variable b1 NUMBER;

BEGIN

  --:b1 := 82771880 ;
  :b1 := 16109 ;

END;
/

set timing on

SELECT
    consignmen0_.id                        AS id1_35_,
    consignmen0_.adoption_start_date       AS adoption_start_dat8_35_,
    consignmen0_.created_by                AS created_by2_35_,
    consignmen0_.date_created              AS date_created3_35_,
    consignmen0_.date_modified             AS date_modified4_35_,
    consignmen0_.modified_by               AS modified_by5_35_,
    consignmen0_.version                   AS version6_35_,
    consignmen0_.adoption_end_date         AS adoption_end_date7_35_,
    consignmen0_.adoption_start_date       AS adoption_start_dat8_35_,
    consignmen0_.arrival_time_drv          AS arrival_time_drv9_35_,
    consignmen0_.csm_id                    AS csm_id15_35_,
    consignmen0_.departure_time_drv        AS departure_time_dr10_35_,
    consignmen0_.forwarder_ref_code        AS forwarder_ref_cod11_35_,
    consignmen0_.ogn_id                    AS ogn_id16_35_,
    consignmen0_.ogn_id_cha                AS ogn_id_cha17_35_,
    consignmen0_.pca_uuid                  AS pca_uuid12_35_,
    consignmen0_.por_id_loading            AS por_id_loading18_35_,
    consignmen0_.un_code_drv               AS un_code_drv13_35_,
    consignmen0_.usr_id                    AS usr_id19_35_,
    consignmen0_.vessel_display_name_drv   AS vessel_display_na14_35_,
    consignmen0_.vis_id                    AS vis_id20_35_
FROM
    pcs.pil_consignment_adoptions consignmen0_
    LEFT OUTER JOIN pcs.pil_consignments consignmen1_ ON consignmen0_.csm_id = consignmen1_.id
WHERE
    consignmen1_.id = :b1
    AND ( consignmen0_.id IN (
        SELECT
            consignmen2_.id
        FROM
            pcs.pil_consignment_adoptions_v consignmen2_
    ) )
/

set autotrace on

/

set autotrace off

-- now using V2

SELECT
    consignmen0_.id                        AS id1_35_,
    consignmen0_.adoption_start_date       AS adoption_start_dat8_35_,
    consignmen0_.created_by                AS created_by2_35_,
    consignmen0_.date_created              AS date_created3_35_,
    consignmen0_.date_modified             AS date_modified4_35_,
    consignmen0_.modified_by               AS modified_by5_35_,
    consignmen0_.version                   AS version6_35_,
    consignmen0_.adoption_end_date         AS adoption_end_date7_35_,
    consignmen0_.adoption_start_date       AS adoption_start_dat8_35_,
    consignmen0_.arrival_time_drv          AS arrival_time_drv9_35_,
    consignmen0_.csm_id                    AS csm_id15_35_,
    consignmen0_.departure_time_drv        AS departure_time_dr10_35_,
    consignmen0_.forwarder_ref_code        AS forwarder_ref_cod11_35_,
    consignmen0_.ogn_id                    AS ogn_id16_35_,
    consignmen0_.ogn_id_cha                AS ogn_id_cha17_35_,
    consignmen0_.pca_uuid                  AS pca_uuid12_35_,
    consignmen0_.por_id_loading            AS por_id_loading18_35_,
    consignmen0_.un_code_drv               AS un_code_drv13_35_,
    consignmen0_.usr_id                    AS usr_id19_35_,
    consignmen0_.vessel_display_name_drv   AS vessel_display_na14_35_,
    consignmen0_.vis_id                    AS vis_id20_35_
FROM
    pcs.pil_consignment_adoptions consignmen0_
    LEFT OUTER JOIN pcs.pil_consignments consignmen1_ ON consignmen0_.csm_id = consignmen1_.id
WHERE
    consignmen1_.id = :b1
    AND ( consignmen0_.id IN (
        SELECT
            consignmen2_.id
        FROM
            pcs.pil_consignment_adoptions_v_v2 consignmen2_
         where consignmen2_.csm_id = :b1
    ) )
/

set autotrace on

/

set autotrace off

spool off


