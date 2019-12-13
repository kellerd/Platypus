-- Start of DDL Script for Function TIPS.FN_DEPLOYMENT_CALCULATOR
-- Generated 2019-11-14 3:06:05 PM from TIPS@TIPSUAT.WORLD

CREATE OR REPLACE 
FUNCTION fn_deployment_calculator
  ( v_substantive_group_ind        pay_rates.pra_group_ind%TYPE,
    v_substantive_subgroup_ind     pay_rates.pra_subgroup_ind%TYPE,
    v_substantive_level_ind        pay_rates.pra_level_ind%TYPE,
    v_substantive_bud_code_txt     pay_rates.pra_bud_code%TYPE,
    v_acting_group_ind             pay_rates.pra_group_ind%TYPE,
    v_acting_subgroup_ind          pay_rates.pra_subgroup_ind%TYPE,
    v_acting_level_ind             pay_rates.pra_level_ind%TYPE,
    v_acting_bud_code_txt          pay_rates.pra_bud_code%TYPE
  )
  RETURN  VARCHAR2 IS
--
-- Purpose: Function to return the deployment status
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_deployment_status  VARCHAR2(30);

BEGIN
  SELECT
       CASE
         WHEN MAX(act.pra_salary_amount) - MAX(sub.pra_salary_amount) > MIN(sub.step_increment) AND
              MAX(act.pra_salary_amount) - MAX(sub.pra_salary_amount) > 0 THEN
              'PROMOTION'
         WHEN MAX(act.pra_salary_amount) - MAX(sub.pra_salary_amount) = MIN(sub.step_increment) THEN
              'DEPLOYMENT'
         WHEN MAX(act.pra_salary_amount) - MAX(sub.pra_salary_amount) < MIN(sub.step_increment) AND
              MAX(act.pra_salary_amount) - MAX(sub.pra_salary_amount) > MIN(sub.step_increment)*-1 THEN
              'DEPLOYMENT'
         WHEN MAX(act.pra_salary_amount) IS NULL OR
              MAX(sub.pra_salary_amount) IS NULL THEN
              'N/A'
         ELSE
              'DEMOTION'
         END
  INTO v_deployment_status
  FROM vw_hrsr_deployment_calculator sub,
       vw_hrsr_deployment_calculator act
 WHERE sub.pra_group_ind = v_substantive_group_ind
   AND sub.pra_subgroup_ind = NVL(v_substantive_subgroup_ind,'   ')
   AND sub.pra_level_ind = v_substantive_level_ind
   AND sub.pra_bud_code = NVL(v_substantive_bud_code_txt, sub.pra_bud_code) -- If no BUD code passed in, return all
   AND act.pra_group_ind = v_acting_group_ind
   AND act.pra_subgroup_ind = NVL(v_acting_subgroup_ind,'   ')
   AND act.pra_level_ind = v_acting_level_ind
   AND act.pra_bud_code = NVL(v_acting_bud_code_txt,act.pra_bud_code); -- If no BUD code passed in, return all

   RETURN v_deployment_status;


EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL  ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM FN_DEPLOYMENT_CALCULATOR
  FOR TIPS.FN_DEPLOYMENT_CALCULATOR
/  
  
-- Grants for Function
GRANT EXECUTE ON fn_deployment_calculator TO tipsuser
/
GRANT EXECUTE ON fn_deployment_calculator TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_DEPLOYMENT_CALCULATOR

