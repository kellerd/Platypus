--SELECT * FROM TH189_EMPLOYMENT_TYPE;

INSERT INTO th189_employment_type (employment_type_cd, employment_type_enm, employment_type_fnm, display_order_num)
  SELECT glv_val_value_ind, glv_val_desc_e, glv_val_desc_f, glv_display_seq_nmbr
    FROM global_validations
   WHERE glv_val_name = 'EMPLOYMENT_TYPE'
     AND glv_val_category_ind = 'GLB' ;
     
COMMIT;
     
