
UPDATE global_validations 
   SET glv_val_desc_f = 'Langues officielles - à revoir avant de doter'
 WHERE glv_val_category_ind = 'CLS'
   AND glv_val_name = 'CLASSIFICATION_FLAG'
   AND glv_val_value_ind = 'OL'; 
   
COMMIT;
   
