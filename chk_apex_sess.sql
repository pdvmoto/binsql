/* 
select item_name, component_comment
      ,apex_util.get_session_state(item_name) session_value
from  apex_application_page_items
where application_id is not null -- = :APP_ID
and   page_id        is not null -- = :APP_PAGE_ID
*/ 

column apx_usr format A30
column remote_addr format A20
column workspace_userid format 999,999,999,999,999,999,999

select s.username  apx_usr
, remote_addr
, workspace_user_id
-- , s.* 
from apex_050000.wwv_flow_sessions$ s 
order by s.username
/

