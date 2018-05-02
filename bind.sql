
var a varchar2(3) ;

begin 
  :a := 'a';
  end ;
/

select :a from dual ;



-- some settings to re-set

alter session set optimizer_index_caching = 0 ;
alter session set optimizer_index_cost_adj = 100;


