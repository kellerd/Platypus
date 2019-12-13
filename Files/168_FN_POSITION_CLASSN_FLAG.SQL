-- Start of DDL Script for Function TIPS.FN_POSITION_CLASSN_FLAG
-- Generated 2019-08-13 10:43:11 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_position_classn_flag
  ( v_position_nmbr       positions.pos_position_nmbr%TYPE,
    v_hrsr_action_cd      th048_hrsr_action.act_action_cd%TYPE
  )
  RETURN  INTEGER IS
--
-- Purpose: Function to return if the position is flagged by classification.
--          Developed for HRSR 2.0
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
--
   v_classifiction_flag  INTEGER;

BEGIN

  -- Check for Flagged Process 2:
  -- These flags are a hard stop in the application, and the user has to contact
  -- the Classification advisor to continue the process.
  FOR classn_flag_rec IN (
      SELECT pcl_classification_flag,
             glv_val_desc_e,
             glv_val_desc_f
        FROM position_classification_flag,
             global_validations
       WHERE pcl_position_nmbr = v_position_nmbr
         AND SYSDATE BETWEEN pcl_start_date AND NVL(pcl_end_date, SYSDATE + 1)
         AND glv_val_category_ind = 'CLS'
         AND glv_val_name = 'CLASSIFICATION_FLAG'
         AND glv_val_value_ind = pcl_classification_flag
  ) LOOP

    -- Check if any of the classification flag and action type combinations
    -- fit either the Type 2 classification flag or Type 1. Type 2 types cannot
    -- continue without intervention from Classification to remove the flag
    -- temporarily. Type 1 return a for your info type error only. Type 2 must
    -- be checked first.
    --
    -- Check for Flagged Process 2:
    --   1. A pop-up will appear when this position is selected stating “This
    --      position is flagged. Please send an email to <Classification> to
    --      request a temporary suspension. You will not be able to complete
    --      this action unless the flag is suspended.”
    --   2. Clients will be able to “Send to Recommender”, “Send to Initiator”
    --      but not “Approve” or “Complete Assignment”.
    --   3. Classification will have a business process for if / when / how LONG
    --      they lift the flag in order for the request to allow the “Approve”
    --      or “Complete Assignment” to function.
    IF classn_flag_rec.pcl_classification_flag IN ('SG',       -- Position subject to grievance
                                                   'OT' ) THEN -- Other
       -- All actions, set flag process #2:
       v_classifiction_flag := 2;

    ELSIF classn_flag_rec.pcl_classification_flag = 'SD' AND
       v_hrsr_action_cd NOT IN ('26',       -- Acting < 4 Months
                                '27',       -- Casual
                                '00',       -- TBD / Part-Time Worker **
                                '00',       -- TBD / Term Extension   **
                                '28') THEN  -- Student
        v_classifiction_flag := 2;

    ELSIF classn_flag_rec.pcl_classification_flag IN  ('FA',
                                                       'OL',
                                                       'SR',
                                                       'ST' ) AND
       v_hrsr_action_cd IN ('00',       -- TBD / Indeterminate  **
                            '00',       -- TBD / Term – initial assignment  **
                            '00') THEN  -- TBD / Acting > 12 month  **
       v_classifiction_flag := 2;

    END IF;

    IF v_classifiction_flag = '2' THEN
       RETURN v_classifiction_flag;

    ELSE
    -- Flag #2 has not been raised and we can check for Flag #1
    --
    -- Check for Flagged Process 1:
    --   1. A pop-up will appear when the position is selected stating “This
    --      position has a ZZ flag but you may proceed with this action.”
    --   2. Automatically suspend flag temporarily for the few seconds it takes
    --      to create the assignment when “Create Assignment” button is pressed.

       IF classn_flag_rec.pcl_classification_flag IN  ('FA',
                                                       'OL',
                                                       'SR',
                                                       'ST' ) AND
          v_hrsr_action_cd IN ('26',       -- Acting < 4 Months
                               '27',       -- Casual
                               '28',       -- Student
                               '00',       -- TBD / Part-Time Worker **
                               '00',       -- TBD / Term Extension   **
                               '00',       -- TBD / Interchange Canada **
                               '00',       -- TBD / Internal Assignment
                               '00') THEN  -- TBD / Secondment
          v_classifiction_flag := 1;

       ELSIF classn_flag_rec.pcl_classification_flag = 'SD' AND
          v_hrsr_action_cd IN ('26',       -- Acting < 4 Months
                               '27',       -- Casual
                               '28',       -- Student
                               '00',       -- TBD / Part-Time Worker **
                               '00') THEN  -- TBD / Term Extension   **
          v_classifiction_flag := 1;

       END IF;
    END IF;

  END LOOP;

    IF v_classifiction_flag IN ('1', '2') THEN
       RETURN v_classifiction_flag;
    ELSE
       RETURN NULL;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_position_classn_flag
  FOR fn_position_classn_flag
/  

-- Grants for Function
GRANT EXECUTE ON fn_position_classn_flag TO tipsuser
/
GRANT EXECUTE ON fn_position_classn_flag TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_POSITION_CLASSN_FLAG

