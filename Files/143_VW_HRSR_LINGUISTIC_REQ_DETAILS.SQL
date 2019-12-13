-- Start of DDL Script for View TIPS.VW_HRSR_LINGUISTIC_REQ_DETAILS
-- Generated 2019-07-09 10:18:56 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_linguistic_req_details (
   position_nmbr,
   communication_factor_cd,
   communication_factor_enm,
   communication_factor_fnm,
   rating_dte,
   rating_ind )
AS
SELECT cop_position_nmbr       AS position_nmbr,
       cop_comm_factor_ind     AS communication_factor_cd,
       glv_val_desc_e          AS communication_factor_enm,
       glv_val_desc_f          AS communication_factor_fnm,
       cop_rating_date         AS rating_dte,
       cop_comm_rating_ind     AS rating_ind
  FROM communication_profiles,
       global_validations
 WHERE cop_comm_factor_ind = glv_val_value_ind
   AND glv_val_category_ind = 'OL'
   AND glv_val_name = 'COMMUNICATION_RATING_FACTOR'
/

CREATE OR REPLACE PUBLIC SYNONYM VW_HRSR_LINGUISTIC_REQ_DETAILS
  FOR TIPS.VW_HRSR_LINGUISTIC_REQ_DETAILS
/
GRANT SELECT ON VW_HRSR_LINGUISTIC_REQ_DETAILS TO TIPSUSER
/
GRANT SELECT ON VW_HRSR_LINGUISTIC_REQ_DETAILS TO EVERYTHING_IN_TIPS
/
  
-- End of DDL Script for View TIPS.VW_HRSR_LINGUISTIC_REQ_DETAILS

