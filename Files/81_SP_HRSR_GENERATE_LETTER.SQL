-- Start of DDL Script for Procedure TIPS.SP_HRSR_GENERATE_LETTER
-- Generated 2019-05-27 3:48:16 PM from TIPS@TIPSUAT.WORLD

CREATE OR REPLACE 
PROCEDURE sp_hrsr_generate_letter (
  v_hrsr_request_nmbr   ah027_hrsr_request.rqt_hrsr_request_cd%TYPE,
  v_letter_id           ah098_hrsr_letter.hrsr_letter_id%TYPE,
  v_language_ind        th019_language.lng_language_cd%TYPE,
  v_letter_txt          OUT CLOB
  )
   IS
-- Created by: Jennifer Hynes Tuttle, 29-APR-2019
--
-- Purpose: This stored procedure will generate an HRSR Letter of Offer and
--          send it back to the application.
--
--          NOTE: Maximun length of sql statement is set to 32K.
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ------     -------------------------------------------------------
--

    v_statement             VARCHAR2(32767);
    v_len                   number;
    v_count                 number;
    v_new_letter_id         ah098_hrsr_letter.hrsr_letter_id%TYPE;


BEGIN


  FOR hrsr_request_rec IN (
      SELECT *
        FROM ah027_hrsr_request
       WHERE rqt_hrsr_request_cd = v_hrsr_request_nmbr
  ) LOOP

    IF hrsr_request_rec.rqt_action_cd IN ('13', '27') THEN   -- Casual

     FOR casual_letter_data IN (
         SELECT DISTINCT *
           FROM vw_hrsr_casual_letter_data
          WHERE hrsr_request_cd = v_hrsr_request_nmbr
     ) LOOP

       SELECT MAX(hrsr_letter_id)
         INTO v_new_letter_id
         FROM ah098_hrsr_letter
        WHERE upper(hrsr_letter_enm) = 'CASUAL';

       FOR hrsr_letter_template IN
           (SELECT hrsr_letter_body_etxt
              FROM vw_hrsr_letter_template
             WHERE hrsr_letter_id = v_new_letter_id
             ORDER BY hrsr_letter_section_id,
                      section_display_order_num,
                      body_display_order_num
           ) LOOP

           v_letter_txt := v_letter_txt|| CHR(13) || CHR(13)||
                           hrsr_letter_template.hrsr_letter_body_etxt;

       END LOOP;

      -- Replace all token values with valid data:

       v_letter_txt :=
        REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
           REPLACE(v_letter_txt,
            '<v_current_date_etxt>',         TO_CHAR(TRUNC(SYSDATE),'DD MON YYYY')),
            '<v_current_date_ftxt>',         tips.get_formatted_bilingual_date(trunc(sysdate), 1)),
            '<v_hrsr_request_cd>',           casual_letter_data.hrsr_request_cd),
            '<v_selection_process_nmbr>',    casual_letter_data.selection_process_nmbr),
            '<v_candidate_given_name>',      casual_letter_data.candidate_given_name_txt),
            '<v_candidate_family_name>',     casual_letter_data.candidate_family_name_txt),
            '<v_candidate_pri>',             casual_letter_data.candidate_pin),
            '<v_position_nmbr>',             casual_letter_data.position_nmbr),
            '<v_position_title_enm>',        casual_letter_data.position_title_enm),
            '<v_position_title_enm>',        casual_letter_data.position_title_fnm),
            '<v_position_classn_txt>',       casual_letter_data.pos_classn),
            '<v_pos_lang_enm>',              casual_letter_data.pos_lang_enm),
            '<v_pos_lang_fnm>',              casual_letter_data.pos_lang_fnm),
            '<v_extension_enm>',             casual_letter_data.extension_enm),
            '<v_extension_fnm>',             casual_letter_data.extension_fnm),
            '<v_branch_enm>',                casual_letter_data.admin_group_enm),
            '<v_branch_fnm>',                casual_letter_data.admin_group_fnm),
            '<v_directorate_enm>',           casual_letter_data.directorate_enm),
            '<v_directorate_fnm>',           casual_letter_data.directorate_fnm),
            '<v_region_enm>',                casual_letter_data.region_enm),
            '<v_region_fnm>',                casual_letter_data.region_fnm),
            '<v_location>',                  casual_letter_data.position_location),
            '<assignment_type_enm>',         casual_letter_data.assignment_type_enm),
            '<assignment_type_fnm>',         casual_letter_data.assignment_type_fnm),
            '<v_signature_line>',            casual_letter_data.approver_name),
--            '<v_manager_email>',             casual_letter_data.approver_email_txt),
            '<v_security_clearance_enm>',    casual_letter_data.security_clearance_enm),
            '<v_security_clearance_fnm>',    casual_letter_data.security_clearance_fnm),
            '<v_salary_enm>',                casual_letter_data.salary_enm),
            '<v_salary_fnm>',                casual_letter_data.salary_fnm),
            '<v_opt_allowances_enm>',        NULL),
            '<v_opt_allowances_fnm>',        NULL),
            '<v_aww>',                       NVL(casual_letter_data.aww,'0')),
            '<v_custom_emp_cond_etxt>',      CASE
                                               WHEN casual_letter_data.cond_of_employ_etxt IS NOT NULL OR
                                                    casual_letter_data.custom_cond_of_employ_etxt IS NOT NULL THEN
                                                 CHR(13)||CHR(13)||'Other Conditions of Employment:'||CHR(13)||
                                                 casual_letter_data.cond_of_employ_etxt||
                                                 casual_letter_data.custom_cond_of_employ_etxt
                                               END),
            '<v_custom_emp_cond_ftxt>',      CASE
                                                WHEN casual_letter_data.cond_of_employ_ftxt IS NOT NULL OR
                                                    casual_letter_data.custom_cond_of_employ_ftxt IS NOT NULL THEN
                                                 CHR(13)||CHR(13)||'Autres conditions d’emploi:'||CHR(13)||
                                                 casual_letter_data.cond_of_employ_ftxt||
                                                 casual_letter_data.custom_cond_of_employ_ftxt
                                               END),
            '<v_asn_start_dte_enm>',         TO_CHAR(casual_letter_data.asn_start_dte,'DD-MON-YYYY')),
            '<v_asn_end_dte_enm>',           TO_CHAR(casual_letter_data.asn_end_dte,'DD-MON-YYYY')),
            '<v_asn_start_dte_fnm>',         tips.get_formatted_bilingual_date(casual_letter_data.asn_start_dte,1)),
            '<v_asn_end_dte_fnm>',           tips.get_formatted_bilingual_date(casual_letter_data.asn_end_dte,1)) ;

     END LOOP;


    ELSIF hrsr_request_rec.rqt_action_cd IN ('20','28') THEN -- Student

     FOR student_letter_data IN (
         SELECT DISTINCT *
           FROM vw_hrsr_student_letter_data
          WHERE hrsr_request_cd = v_hrsr_request_nmbr
     ) LOOP

       IF student_letter_data.aboriginal_program_ind = '1' THEN
          SELECT MAX(hrsr_letter_id)
            INTO v_new_letter_id
            FROM ah098_hrsr_letter
           WHERE upper(hrsr_letter_enm) LIKE '%STUDENT%ABO%';
       ELSE
          SELECT MIN(hrsr_letter_id)
            INTO v_new_letter_id
            FROM ah098_hrsr_letter
           WHERE upper(hrsr_letter_enm) = 'STUDENT';
       END IF;

       FOR hrsr_letter_template IN
           (SELECT hrsr_letter_body_etxt
              FROM vw_hrsr_letter_template
             WHERE hrsr_letter_id = v_new_letter_id
             ORDER BY hrsr_letter_section_id,
                      section_display_order_num,
                      body_display_order_num
           ) LOOP

           v_letter_txt := v_letter_txt|| CHR(13) || CHR(13)||
                           hrsr_letter_template.hrsr_letter_body_etxt;

       END LOOP;

      -- Replace all token values with valid data:

       v_letter_txt :=
        REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
         REPLACE(
           REPLACE(v_letter_txt,
            '<v_current_date_etxt>',         TO_CHAR(TRUNC(SYSDATE),'DD MON YYYY')),
            '<v_current_date_ftxt>',         tips.get_formatted_bilingual_date(trunc(sysdate), 1)),
            '<v_hrsr_request_cd>',           student_letter_data.hrsr_request_cd),
            '<v_selection_process_nmbr>',    student_letter_data.selection_process_nmbr),
            '<v_candidate_given_name>',      student_letter_data.candidate_given_name_txt),
            '<v_candidate_family_name>',     student_letter_data.candidate_family_name_txt),
            '<v_position_title_enm>',        student_letter_data.position_title_enm),
            '<v_position_title_enm>',        student_letter_data.position_title_fnm),
            '<v_branch_enm>',                student_letter_data.admin_group_enm),
            '<v_branch_fnm>',                student_letter_data.admin_group_fnm),
            '<v_directorate_enm>',           student_letter_data.directorate_enm),
            '<v_directorate_fnm>',           student_letter_data.directorate_fnm),
            '<v_region_enm>',                student_letter_data.region_enm),
            '<v_region_fnm>',                student_letter_data.region_fnm),
            '<v_location>',                  student_letter_data.position_location),
            '<assignment_type_enm>',         student_letter_data.assignment_type_enm),
            '<assignment_type_fnm>',         student_letter_data.assignment_type_fnm),
            '<v_signature_line>',            student_letter_data.approver_name),
--            '<v_manager_email>',             student_letter_data.approver_email_txt),
            '<v_security_clearance_enm>',    student_letter_data.security_clearance_enm),
            '<v_security_clearance_fnm>',    student_letter_data.security_clearance_fnm),
            '<v_salary_enm>',                student_letter_data.salary_enm),
            '<v_salary_fnm>',                student_letter_data.salary_fnm),
            '<v_aww>',                       NVL(student_letter_data.aww,'0')),
            '<v_custom_emp_cond_etxt>',      CASE
                                               WHEN student_letter_data.cond_of_employ_etxt IS NOT NULL OR
                                                    student_letter_data.custom_cond_of_employ_etxt IS NOT NULL THEN
                                                 CHR(13)||CHR(13)||'Other Conditions of Employment:'||CHR(13)||
                                                 student_letter_data.cond_of_employ_etxt||
                                                 student_letter_data.custom_cond_of_employ_etxt
                                               END),
            '<v_custom_emp_cond_ftxt>',      CASE
                                                WHEN student_letter_data.cond_of_employ_ftxt IS NOT NULL OR
                                                    student_letter_data.custom_cond_of_employ_ftxt IS NOT NULL THEN
                                                 CHR(13)||CHR(13)||'Autres conditions d’emploi:'||CHR(13)||
                                                 student_letter_data.cond_of_employ_ftxt||
                                                 student_letter_data.custom_cond_of_employ_ftxt
                                               END),
            '<v_asn_start_dte_enm>',         TO_CHAR(student_letter_data.asn_start_dte,'DD-MON-YYYY')),
            '<v_asn_end_dte_enm>',           TO_CHAR(student_letter_data.asn_end_dte,'DD-MON-YYYY')),
            '<v_asn_start_dte_fnm>',         tips.get_formatted_bilingual_date(student_letter_data.asn_start_dte,1)),
            '<v_asn_end_dte_fnm>',           tips.get_formatted_bilingual_date(student_letter_data.asn_end_dte,1)) ;


     END LOOP;
    END IF;
  END LOOP;
END;
/

-- Grants for Procedure
GRANT EXECUTE ON sp_hrsr_generate_letter TO tipsuser
/
GRANT EXECUTE ON sp_hrsr_generate_letter TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SP_HRSR_GENERATE_LETTER

