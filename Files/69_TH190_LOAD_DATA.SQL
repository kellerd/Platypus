--SELECT * FROM TH190_XREF_TH048_TH189;

INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '11',
            glv_val_value_ind
       FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'A' AND 'H'
             OR glv_val_value_ind IN ('S', 'T'));

INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '12',
            glv_val_value_ind
       FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'A' AND 'H'
             OR glv_val_value_ind IN ('S', 'T'));
             
             
-- Casuals:
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '13',
            glv_val_value_ind 
       FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND glv_val_value_ind IN ('K','L','M','P','R', 'I');
   
   
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '14',
            glv_val_value_ind
       FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'A' AND 'H'
             OR glv_val_value_ind IN ('S', 'T'));


INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '15',
            glv_val_value_ind
       FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'A' AND 'H'
             OR glv_val_value_ind IN ('S', 'T'));


INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '16',
            glv_val_value_ind  FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'A' AND 'H'
             OR glv_val_value_ind IN ('S', 'T'));


INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '19',
            glv_val_value_ind  FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'A' AND 'H'
             OR glv_val_value_ind IN ('S', 'T'));
 
-- Students
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '20',
            glv_val_value_ind  FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND (glv_val_value_ind BETWEEN 'U' AND 'W'
             OR glv_val_value_ind IN ('M','N','Y'));

 -- Visiting Fellows
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '22',
            glv_val_value_ind
       FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
        AND glv_val_value_ind IN ('X', 'Z');

 -- Indeterminate and Term:
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd)
     SELECT '23',
            glv_val_value_ind  FROM global_validations
      WHERE glv_val_category_ind = 'GLB'
        AND glv_val_name = 'EMPLOYMENT_TYPE'
         AND glv_val_value_ind IN ('A', 'B', 'E', 'F', 'G', 'H', 'S', 'T');
         
COMMIT;
         
