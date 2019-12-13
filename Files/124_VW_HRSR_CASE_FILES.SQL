-- Start of DDL Script for View TIPS.VW_HRSR_CASE_FILES
-- Generated 11-Jun-19 7:35:03 from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_case_files (
   hrsr_request_cd,
   case_file_nmbr,
   bf_subject_code,
   hrsr_action_cd,
   bf_action_ind,
   bf_action_enm,
   bf_action_fnm,
   bf_action_etxt,
   bf_action_ftxt,
   bf_category_ind,
   bf_submitted_dte,
   bf_status_change_dte,
   bf_status_ind,
   bf_status_enm,
   bf_status_fnm )
AS
SELECT ah029.stf_hrsr_request_cd      AS hrsr_request_cd,
       caf.caf_case_nmbr              AS case_file_nmbr,
       caf.caf_object_code            AS bf_subject_code,  -- PRI or Position Nmbr
       ah027.rqt_action_cd            AS hrsr_action_cd,
       caf.caf_action_ind             AS bf_action_ind,
       fua.fua_action_code_e          AS bf_action_enm,
       fua.fua_action_code_f          AS bf_action_fnm,
       fua.fua_action_desc_e          AS bf_action_etxt,
       fua.fua_action_desc_f          AS bf_action_ftxt,
       caf.caf_category_ind           AS bf_category_ind,
       caf.caf_bf_activate_date       AS bf_submitted_dte,
       caf.caf_status_change_datetime AS bf_status_change_dte,
       caf.caf_case_status_ind        AS bf_status_ind,
       glb.glv_val_desc_e             AS bf_status_enm,
       glb.glv_val_desc_f             AS bf_status_fnm
  FROM ah027_hrsr_request     ah027,
       ah029_hrsr_staffing    ah029,
       ah067_xref_ah027_caf   ah067,
       case_files             caf,
       function_actions       fua,
       global_validations     glb
WHERE ah027.rqt_hrsr_request_cd = ah029.stf_hrsr_request_cd
   AND ah029.stf_hrsr_request_cd = ah067.rcf_hrsr_request_cd(+)
   AND ah067.rcf_case_file_nmbr = caf.caf_case_nmbr(+)
   AND caf.caf_action_ind = fua.fua_action_ind(+)
   AND glb.glv_val_category_ind = 'STF'
   AND glb.glv_val_name = 'CASE_STATUS'
   AND caf.caf_case_status_ind = glb.glv_val_value_ind
/

CREATE OR REPLACE PUBLIC SYNONYM VW_HRSR_CASE_FILES FOR TIPS.VW_HRSR_CASE_FILES;

GRANT SELECT ON VW_HRSR_CASE_FILES TO TIPSUSER;
GRANT SELECT ON VW_HRSR_CASE_FILES TO EVERYTHING_IN_TIPS;


-- End of DDL Script for View TIPS.VW_HRSR_CASE_FILES

