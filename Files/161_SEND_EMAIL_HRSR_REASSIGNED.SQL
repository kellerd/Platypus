-- Start of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_REASSIGNED
-- Generated 23-Oct-19 7:06:23 from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE send_email_hrsr_reassigned
   ( v_email_message_id    email_settings.ese_email_id%TYPE,
     v_hrsr_request_cd     ah027_hrsr_request.rqt_hrsr_request_cd%TYPE,
     v_comment_txt         ah033_hrsr_request_comment.cmt_comment_txt%TYPE,
     v_return_message_nmbr OUT NUMBER
)
   IS
--
-- Created by: Jennifer Hynes, 07-AUG-19
--
-- Purpose: This procedure will create and send an email to when an HRSR is
--          reassigned. Emails sent are:
--
--          * 109   HRSR    Forward to Recommender
--          * 110   HRSR    Forward to Approver
--
--          * 111   HRSR    Returned to Initiator
--          * 112   HRSR    Returned to Recommender
--          * 113   HRSR    Returned to Approver
--
--          * 114   HRSR    Withdrawn
--          * 115   HRSR    Cancelled by HR
--          * 116   HRSR    Submitted to Compensation for a PRI (CSA ONLY)
--
--          * 117   HRSR    Acting < 4 months, Approved and Completed
--
--          Procedure to be used by the HRSR 2.0 Application
--
-- MODIFICATION HISTORY
-- Person        Date       Comments
-- ---------     --------   ----------------------------------------------------
--

  v_current_instance_name  VARCHAR2(30) := get_db_current_instance_name;
  v_prod_instance_name     VARCHAR2(30) := get_db_prod_instance_name;
  v_uat_message            VARCHAR2(4000);
  v_cc_emails              VARCHAR2(300);

BEGIN

  -- Get the HRSR information information:
  FOR hrsr_info IN (
      SELECT rqt_hrsr_request_cd,
             rqt_action_cd,
             act_hrsr_action_enm,
             act_hrsr_action_fnm,
             (SELECT pou_user_id
                FROM portal_users
               WHERE pou_pri = rqt_initiator_pin) AS initiator_user_id,
             (SELECT pou_user_id
                FROM portal_users
               WHERE pou_pri = rqt_recommender_pin) AS recommender_user_id,
             (SELECT pou_user_id
                FROM portal_users
               WHERE pou_pri = rqt_approver_pin) AS approver_user_id,
             rqt_position_nmbr AS position_nmbr,
             pos_group_ind||pos_subgroup_ind||pos_level_ind AS classn,
             TRIM(NVL(per_family_name, stf_candidate_family_name_txt))||', '||
                 TRIM(NVL(per_given_name, stf_candidate_given_name_txt))  AS candidate_name,
             CASE
               WHEN stf_extension_cd IN ('E', 'X') THEN  -- Extension
                 TRUNC(stf_asn_end_date_dte + 1)         -- Prev end date + 1
               ELSE
                 TRUNC(stf_asn_start_date_dte)
               END                               AS asn_start_dte,
             CASE
               WHEN stf_extension_cd IN ('E', 'X') THEN -- Extension
                 TRUNC(stf_asn_new_end_date_dte)
               ELSE
                 TRUNC(stf_asn_end_date_dte)
               END                               AS asn_end_dte,
             pou_user_id  AS user_id,
             NVL(pou_communication_lang,'1') AS lang
        FROM ah027_hrsr_request,
             ah029_hrsr_staffing,
             th048_hrsr_action,
             persons,
             positions,
             portal_users
       WHERE rqt_hrsr_request_cd = v_hrsr_request_cd
         AND rqt_hrsr_request_cd = stf_hrsr_request_cd
         AND rqt_action_cd = act_action_cd
         AND stf_candidate_pin = per_pin
         AND per_type_code = '1'
         AND rqt_position_nmbr = pos_position_nmbr
         AND pou_pri(+) =
             CASE
               WHEN v_email_message_id = '111' THEN -- Initiator
                    rqt_initiator_pin
               WHEN v_email_message_id IN ('109','112') THEN -- Recommender
                    rqt_recommender_pin
               WHEN v_email_message_id IN ('110','113') THEN -- Approver
                    rqt_approver_pin
               ELSE rqt_initiator_pin  -- All others will go to Initiator, and
                                       -- CC Recommender and Approver
             END
  ) LOOP

  IF v_email_message_id IN ('114',      -- Withdrawn
                            '115',      -- Cancelled by HR
                            '117') THEN  -- Acting < 4 mths approved
     -- cc the Recommender and Approver, if different from Initiator:
     FOR cc_rec IN (
          SELECT hrsr_info.recommender_user_id AS cc_user_id FROM dual
           WHERE hrsr_info.initiator_user_id != hrsr_info.recommender_user_id
          UNION ALL
          SELECT hrsr_info.approver_user_id AS cc_user_id FROM dual
           WHERE hrsr_info.initiator_user_id != hrsr_info.approver_user_id
     ) LOOP

     v_cc_emails := v_cc_emails||' '||tips.get_smtp_email_address(cc_rec.cc_user_id)||'; ';

     END LOOP;
  END IF;



    -- Set the email setting variables:
    FOR email_settings IN (
        SELECT DECODE(v_current_instance_name,  -- If not Prod, send test email
                      v_prod_instance_name, emt_sender_email_address,
                              ese_test_email_account) AS sender_email,
               emt_sender_email_address AS sender_test,
               DECODE(v_current_instance_name,  -- If not Prod, send test email
                      v_prod_instance_name,
                        DECODE(v_email_message_id, '116', emt_recipient_domain,
                               tips.get_smtp_email_address(hrsr_info.user_id)),
                      ese_test_email_account) AS recipient_email,
               DECODE(v_email_message_id, '116', emt_recipient_domain,
                      tips.get_smtp_email_address(hrsr_info.user_id))
                    AS recipient_test,
               DECODE(v_current_instance_name,  -- If not Prod, send test email
                      v_prod_instance_name,
                        v_cc_emails,
                        ese_test_email_account) AS cc_email,
               v_cc_emails AS cc_test,
               ese_mailhost,
               ese_mailport,
               REPLACE(
                 DECODE(hrsr_info.lang,
                        '2',emt_subject_text_f||' / '||emt_subject_text_e,
                            emt_subject_text_e||' / '||emt_subject_text_f),
                 '<hrsr_request_cd>', v_hrsr_request_cd) AS subject,
               REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
                  DECODE(hrsr_info.lang,
                         '2',emt_message_text_f,
                             emt_message_text_e),
                '<hrsr_request_cd>',   v_hrsr_request_cd),
                '<action_type_enm>',   hrsr_info.act_hrsr_action_enm),
                '<action_type_fnm>',   hrsr_info.act_hrsr_action_fnm),
                '<position_number>',   hrsr_info.position_nmbr),
                '<classification>',    hrsr_info.classn),
                '<candidate_name>',    hrsr_info.candidate_name),
                '<v_start_date>',      hrsr_info.asn_start_dte),
                '<v_end_date>',        hrsr_info.asn_end_dte),
                '<v_comment_txt>',     v_comment_txt)
                AS message
          FROM email_settings,
               email_message_text
         WHERE ese_email_id = v_email_message_id
           AND emt_email_id = ese_email_id
        ) LOOP
          -- Set the UAT message which will store the TO / FROM information:
          IF v_current_instance_name != v_prod_instance_name THEN
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

  -- Set Success return message number:
  v_return_message_nmbr := 0;

EXCEPTION
 WHEN utl_smtp.Transient_Error OR
      utl_smtp.Permanent_Error THEN
      v_return_message_nmbr := 999;
 WHEN OTHERS THEN
      v_return_message_nmbr := 999;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM send_email_hrsr_reassigned
  FOR send_email_hrsr_reassigned
/  

-- Grants for Procedure
GRANT EXECUTE ON send_email_hrsr_reassigned TO tipsuser
/
GRANT EXECUTE ON send_email_hrsr_reassigned TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_REASSIGNED



