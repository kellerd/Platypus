-- Start of DDL Script for Function TIPS.FN_GET_MAX_SALARY_FOR_CLASSN
-- Generated 2019-09-18 8:24:31 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_max_salary_for_classn
  ( v_classn_group_ind       pay_rates.pra_group_ind%TYPE,
    v_classn_subgroup_ind    pay_rates.pra_subgroup_ind%TYPE,
    v_classn_level_ind       pay_rates.pra_level_ind%TYPE )
  RETURN  pay_rates.pra_salary_amount%TYPE IS
--
-- Created by: Jennifer Hynes, Sept 18, 2019
--
-- Purpose: Returns the MAX active salary for the classification passed in
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--

BEGIN

  FOR max_pay_rate IN (
      SELECT salary_amt
        FROM vw_hrsr_active_pay_rates
        WHERE classn_group_ind = v_classn_group_ind
          AND classn_subgroup_ind = v_classn_subgroup_ind
          AND classn_level_ind = v_classn_level_ind
        ORDER BY salary_amt DESC
  ) LOOP

    RETURN max_pay_rate.salary_amt;

  END LOOP;
  RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
       RETURN 0;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM FN_GET_MAX_SALARY_FOR_CLASSN
  FOR TIPS.FN_GET_MAX_SALARY_FOR_CLASSN
/  
  
-- Grants for Function
GRANT EXECUTE ON fn_get_max_salary_for_classn TO tipsuser
/
GRANT EXECUTE ON fn_get_max_salary_for_classn TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_GET_MAX_SALARY_FOR_CLASSN

