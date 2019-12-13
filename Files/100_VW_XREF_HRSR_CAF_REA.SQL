-- Start of DDL Script for View TIPS.VW_XREF_HRSR_CAF_REA
-- Generated 2019-05-01 7:29:25 AM from TIPS@TIPSE.WORLD

CREATE OR REPLACE VIEW vw_xref_hrsr_caf_rea (
   ah029_hrsr_request_cd,
   ah067_hrsr_request_cd,
   ah067_case_file_nmbr,
   caf_case_nmbr,
   caf_object_code,
   hrsr_action_cd,
   caf_action_ind,
   caf_category_ind,
   caf_bf_activate_date,
   caf_status_change_datetime,
   caf_case_status_ind,
   rea_case_nmbr,
   rea_selection_process_nmbr,
   position_nmbr,
   rqt_last_update_dte,
   completed_date,
   hrsr_completed_date )
AS
SELECT ah029.stf_hrsr_request_cd      AS ah029_hrsr_request_cd,
       ah067.rcf_hrsr_request_cd      AS ah067_hrsr_request_cd,
       ah067.rcf_case_file_nmbr       AS ah067_case_file_nmbr,
       caf.caf_case_nmbr              AS caf_case_nmbr,
       caf.caf_object_code            AS caf_object_code,
       ah027.rqt_action_cd            AS hrsr_action_cd,
       caf.caf_action_ind             AS caf_action_ind,
       caf.caf_category_ind           AS caf_category_ind,
       caf.caf_bf_activate_date       AS caf_bf_activate_date,
       caf.caf_status_change_datetime AS caf_status_change_datetime,
       caf.caf_case_status_ind        AS caf_case_status_ind,
       rea.rea_case_nmbr              AS rea_case_nmbr,
       rea.rea_selection_process_nmbr AS rea_selection_process_nmbr,
       NVL(ah027.rqt_position_nmbr,
           caf.caf_object_code)       AS position_nmbr,
       ah027.rqt_last_update_dte      AS rqt_last_update_dte,
       (SELECT DECODE(ah027.rqt_hrsr_status_cd, '6', MAX(rqh_last_update_dte),NULL)
          FROM ah035_hrsr_request_history completed
         WHERE ah029.stf_hrsr_request_cd = completed.rqh_hrsr_request_cd(+)
           AND completed.rqh_workflow_action_cd = '9'
           AND EXISTS (SELECT *
                         FROM all_assignments
                        WHERE asn_position_nmbr = ah027.rqt_position_nmbr
                          AND TRUNC(rqh_last_update_dte,'HH') =
                              TRUNC(asn_approval_received_date,'HH'))) AS completed_date,
       (SELECT DECODE(ah027.rqt_hrsr_status_cd,
                '6', NVL(NVL(MAX(rqh_last_update_dte),NULL),
                     caf.caf_status_change_datetime) ,ah027.rqt_last_update_dte,
                     NULL)
          FROM ah035_hrsr_request_history completed
         WHERE ah029.stf_hrsr_request_cd = completed.rqh_hrsr_request_cd(+)
           AND completed.rqh_workflow_action_cd = '9'
           AND EXISTS (SELECT *
                         FROM all_assignments
                        WHERE asn_position_nmbr = ah027.rqt_position_nmbr
                          AND TRUNC(completed.rqh_last_update_dte,'HH') =
                              TRUNC(asn_approval_received_date,'HH'))) AS hrsr_completed_date
  FROM ah027_hrsr_request     ah027,
       ah029_hrsr_staffing    ah029,
       ah067_xref_ah027_caf   ah067,
       case_files             caf,
       resource_activities    rea
 WHERE ah027.rqt_hrsr_request_cd = ah029.stf_hrsr_request_cd
   AND ah029.stf_hrsr_request_cd = ah067.rcf_hrsr_request_cd(+)
   AND ah067.rcf_case_file_nmbr = caf.caf_case_nmbr(+)
   AND ah067.rcf_case_file_nmbr = rea.rea_case_nmbr(+)
/



-- End of DDL Script for View TIPS.VW_XREF_HRSR_CAF_REA

