--SELECT * FROM th195_education_level;

INSERT INTO th195_education_level (education_level_cd, education_level_enm, education_level_fnm)
SELECT glv_val_value_ind, glv_val_desc_e, glv_val_desc_f
  FROM global_validations 
 WHERE glv_val_name = 'EDUCATION_LEVEL'
 ORDER BY glv_val_value_ind; 

COMMIT;



