-- Start of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_RETURN_TO_USER
-- Generated 2019-06-26 4:43:12 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE send_email_hrsr_return_to_user
   ( v_hrsr_request_cd     ah027_hrsr_request.rqt_hrsr_request_cd%TYPE,
     v_email_recipient_pin portal_users.pou_pri%TYPE,
     v_old_actor_cd        ah027_hrsr_request.rqt_hrsr_actor_cd%TYPE,
     v_new_actor_cd        ah027_hrsr_request.rqt_hrsr_actor_cd%TYPE,
     v_comment_txt         ah033_hrsr_request_comment.cmt_comment_txt%TYPE)
   IS
--
-- Created by: Jennifer Hynes, 26-JUN-19
--
-- Purpose: This procedure will create and send an email to an HRSR person
--
--          * 108   HRSR 2  Return to Previous User
--
--          Procedure to be used by the HRSR 2.0 Application
--
-- MODIFICATION HISTORY
-- Person        Date       Comments
-- ---------  ---------  -------------------------------------------------------
--
--

  v_current_instance_name  VARCHAR2(30) := get_db_current_instance_name;
  v_prod_instance_name     VARCHAR2(30) := get_db_prod_instance_name;
  v_return_message_nmbr    NUMBER;
  v_uat_message            VARCHAR2(4000);


BEGIN

  -- Get the recepient's email information:
  FOR employee_info IN (
      SELECT pou_user_id AS user_id,
             RTRIM(tips.get_first_last_name(pou_pri))  AS employee_name,
             pou_communication_lang                    AS lang,
             from_actor.act_hrsr_actor_description_etx AS from_enm,
             from_actor.act_hrsr_actor_description_ftx AS from_fnm,
             to_actor.act_hrsr_actor_description_etx   AS to_enm,
             to_actor.act_hrsr_actor_description_ftx   AS to_fnm
        FROM portal_users,
             th052_hrsr_actor from_actor,
             th052_hrsr_actor to_actor
       WHERE pou_pri = v_email_recipient_pin
         AND v_old_actor_cd = from_actor.act_hrsr_actor_cd(+)
         AND v_new_actor_cd = to_actor.act_hrsr_actor_cd(+)
  ) LOOP

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
             REPLACE(
             REPLACE(
             REPLACE(
             REPLACE(
               DECODE(employee_info.lang,
                      '2',emt_subject_text_f,
                          emt_subject_text_e),
               '<hrsr_request_cd>', v_hrsr_request_cd),
               '<v_from_actor_enm>', employee_info.from_enm),
               '<v_from_actor_fnm>', employee_info.from_fnm),
               '<v_to_actor_enm>',   employee_info.to_enm),
               '<v_to_actor_fnm>',   employee_info.to_fnm )
               AS subject,
             REPLACE(
             REPLACE(
             REPLACE(
             REPLACE(
             REPLACE(
             REPLACE(
                DECODE(employee_info.lang,
                             '2',emt_message_text_f,
                                 emt_message_text_e),
               '<hrsr_request_cd>', v_hrsr_request_cd),
               '<v_from_actor_enm>', employee_info.from_enm),
               '<v_from_actor_fnm>', employee_info.from_fnm),
               '<v_to_actor_enm>',   employee_info.to_enm),
               '<v_to_actor_fnm>',   employee_info.to_fnm),
               '<v_comment>',        v_comment_txt)
               AS message
        FROM email_settings,
             email_message_text
       WHERE ese_email_id = '108'
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
END; -- Procedure;
/

-- Grants for Procedure
GRANT EXECUTE ON send_email_hrsr_return_to_user TO tipsuser
/
GRANT EXECUTE ON send_email_hrsr_return_to_user TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_RETURN_TO_USER

