-- Start of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR
-- Generated 2019-10-04 2:11:11 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE send_email_hrsr
   ( v_email_message_id    email_settings.ese_email_id%TYPE,
     v_employee_pin        portal_users.pou_pri%TYPE,
     v_hrsr_request_cd     VARCHAR2,
     v_return_message_nmbr OUT NUMBER
   )
   IS
--
-- Created by: Jennifer Hynes,  Sept 30, 2019
--
-- Purpose: This procedure will create and send an email to an HRSR person
--
--          * 063   HRSR    Close Case File
--
--          Procedure to be used by the HRSR 2.0 Application
--
-- MODIFICATION HISTORY
-- Person        Date       Comments
-- ---------     ---------  ----------------------------------------------------
--

  v_current_instance_name  VARCHAR2(30) := get_db_current_instance_name;
  v_prod_instance_name     VARCHAR2(30) := get_db_prod_instance_name;
  v_uat_message            VARCHAR2(4000);
  v_project_plan           VARCHAR2(50);
  v_selection_process_nmbr VARCHAR2(500);
  v_action_type            th048_hrsr_action.act_hrsr_action_enm%TYPE;
  v_position_number        ah027_hrsr_request.rqt_position_nmbr%TYPE;
  v_classification         VARCHAR2(10);
  v_candidate_name         VARCHAR2(65);
  v_candidate_fname        VARCHAR2(40);
  v_candidate_lname        VARCHAR2(40);
  v_candidate_pri          VARCHAR2(40);
  v_t1                     VARCHAR2(4000);
  v_t2                     VARCHAR2(4000);

BEGIN

  -- Get the recepient's email information:
  FOR employee_info IN (
      SELECT pou_user_id AS user_id,
             RTRIM(tips.get_first_last_name(pou_pri)) AS employee_name,
             pou_communication_lang AS lang
        FROM portal_users
       WHERE pou_pri = v_employee_pin
  ) LOOP

    IF v_email_message_id = '063' THEN -- HRSR    Close Case File

       SELECT DECODE(employee_info.lang,
                    '2', th048.act_hrsr_action_fnm,
                     th048.act_hrsr_action_enm),
              NVL(ah027.rqt_position_nmbr,'N/A'),
              DECODE(pos.pos_group_ind||'-'||pos.pos_level_ind,
                     '-','N/A',
                     pos.pos_group_ind||'-'||pos.pos_level_ind),
                     ah029.stf_candidate_given_name_txt,
                     ah029.stf_candidate_family_name_txt,
                     asn.asn_employee_pin
         INTO v_action_type,
              v_position_number,
              v_classification,
              v_candidate_fname,
              v_candidate_lname,
              v_candidate_pri
         FROM ah027_hrsr_request ah027,
              th048_hrsr_action th048,
              positions pos,
              ah029_hrsr_staffing ah029,
              assignments asn
        WHERE ah027.rqt_hrsr_request_cd =v_hrsr_request_cd
          AND ah027.rqt_action_cd=th048.act_action_cd(+)
          AND ah027.rqt_position_nmbr=pos.pos_position_nmbr(+)
          AND ah027.rqt_hrsr_request_cd=asn.asn_hrsr_request_cd(+)
          AND ah027.rqt_hrsr_request_cd=ah029.stf_hrsr_request_cd(+);

        IF v_candidate_fname IS NULL then
            v_candidate_name:= RTRIM(tips.get_person_name(v_candidate_pri));
        ELSE
            v_candidate_name:= v_candidate_fname||' '||v_candidate_lname;
        END IF;

    END IF;

    -- Loop through and get all Selection Process Numbers assoc with this
    -- HRSR Request:
    FOR selection_process_nmbr_rec IN (
        SELECT rea_selection_process_nmbr
          FROM resource_activities
         WHERE rea_case_nmbr IN (SELECT rcf_case_file_nmbr
                                   FROM ah067_xref_ah027_caf
                                  WHERE rcf_hrsr_request_cd =
                                        v_hrsr_request_cd)
    ) LOOP

     IF v_selection_process_nmbr IS NULL THEN
         v_selection_process_nmbr :=
               selection_process_nmbr_rec.rea_selection_process_nmbr;
      ELSE
         v_selection_process_nmbr := v_selection_process_nmbr||', '||
               selection_process_nmbr_rec.rea_selection_process_nmbr;
      END IF;

    END LOOP;

    -- Set the email setting variables:
    FOR email_settings IN (
        SELECT DECODE(v_current_instance_name,  -- If not Prod, send test email
                      v_prod_instance_name, emt_sender_email_address,
                              ese_test_email_account) AS sender_email,
               emt_sender_email_address AS sender_test,
               DECODE(v_current_instance_name,  -- If not Prod, send test email
                      v_prod_instance_name,
                        tips.get_smtp_email_address(employee_info.user_id),
                      ese_test_email_account) AS recipient_email,
               tips.get_smtp_email_address(employee_info.user_id)
                    AS recipient_test,
             DECODE(emt_cc_email_address, NULL, NULL, -- no cc if cc is null
               DECODE(v_current_instance_name,  -- If not Prod, send test email
                      v_prod_instance_name,
                        REPLACE(
                          UPPER(emt_cc_email_address),'<V_USER_ID>',
                          tips.get_smtp_email_address(employee_info.user_id)),
                        ese_test_email_account)) AS cc_email,
             DECODE(emt_cc_email_address, NULL, NULL, -- no cc if cc is null
               REPLACE(UPPER(emt_cc_email_address),'<V_USER_ID>',
                       tips.get_smtp_email_address(employee_info.user_id)))
                       AS cc_test,
             ese_mailhost,
             ese_mailport,
             REPLACE(
               DECODE(employee_info.lang,
                      '2',emt_subject_text_f,
                          emt_subject_text_e),
               '<hrsr_request_cd>',
                   DECODE(v_selection_process_nmbr,NULL,v_hrsr_request_cd,
                          v_hrsr_request_cd||' (' ||
                            v_selection_process_nmbr || ')')) AS subject,
             REPLACE(
              REPLACE(
              REPLACE(
              REPLACE(
              REPLACE(
                DECODE(employee_info.lang,
                      '2',emt_message_text_f,
                          emt_message_text_e),
                '<hrsr_request_cd>',
                   DECODE(v_selection_process_nmbr, NULL, v_hrsr_request_cd,
                          v_hrsr_request_cd|| ' (' ||
                          v_selection_process_nmbr || ')')),
                '<action_type>',v_action_type),
                '<position_number>',v_position_number),
                '<classification>',v_classification),
                '<candidate_name>',v_candidate_name)
              AS message
        FROM email_settings,
             email_message_text
       WHERE ese_email_id = v_email_message_id
         AND emt_email_id = ese_email_id
      ) LOOP
        -- Set the UAT message which will store the TO / FROM information:
        IF v_current_instance_name != v_prod_instance_name THEN
           v_t1:=email_settings.recipient_email;
           v_t2:=email_settings.message;
           v_uat_message := '<I>
                             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<BR>
                             ~~~~ START UAT MESSAGE: Non-Production db only <BR>
                             ~~~~ Database: '||v_current_instance_name||'<BR>
                             ~~~~ From: '||email_settings.sender_test||'<BR>
                             ~~~~ To: '||email_settings.recipient_test||'<BR>
                             ~~~~ CC: '||email_settings.cc_test||'<BR>
                             ~~~~ END UAT MESSAGE <BR>
                             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<BR>
                             </I><BR><BR>';
           TIPS.SEND_EMAIL
             (email_settings.sender_email,
              email_settings.recipient_email,
              email_settings.cc_email,
              email_settings.subject,
              v_uat_message||email_settings.message,
              email_settings.ese_mailhost,
              email_settings.ese_mailport,
              v_return_message_nmbr);
        ELSE
           TIPS.SEND_EMAIL
             (email_settings.sender_email,
              email_settings.recipient_email,
              email_settings.cc_email,
              email_settings.subject,
              email_settings.message,
              email_settings.ese_mailhost,
              email_settings.ese_mailport,
              v_return_message_nmbr);
        END IF;
    END LOOP;
  END LOOP;
EXCEPTION
 WHEN utl_smtp.Transient_Error OR
      utl_smtp.Permanent_Error THEN
      v_return_message_nmbr := 999;
 WHEN OTHERS THEN
      v_return_message_nmbr := 999;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM SEND_EMAIL_HRSR
  FOR SEND_EMAIL_HRSR
/
  
-- Grants for Procedure
GRANT EXECUTE ON SEND_EMAIL_HRSR TO tipsuser
/

-- Grants for Procedure
GRANT EXECUTE ON SEND_EMAIL_HRSR TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR

