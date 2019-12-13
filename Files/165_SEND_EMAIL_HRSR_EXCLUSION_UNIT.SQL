-- Start of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_EXCLUSION_UNIT
-- Generated 2019-08-09 2:03:48 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE send_email_hrsr_exclusion_unit
   ( v_employee_pin            employees.emp_pin%TYPE,
     v_position_nmbr           positions.pos_position_nmbr%TYPE,
     v_email_id                email_message_text.emt_email_id%TYPE,
     v_return_message_nmbr     OUT NUMBER)
   IS
--
-- Created by: Jennifer Hynes, 09-AUG-19
--
-- Purpose: This procedure will be called from HRSR 2.0 stored procedure
--          HRSR_CREATE_STAFFING_ACTION and will send an email to exclusion unit
--          to advise them an acting position was created that may effect
--          excluded positions or employees.
--
--          * Email 118 - Acting assignment functioning as excluded position
--          * Email 119 - Excluded employee acting in a non-excluded position
--
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--
--
  v_current_instance_name  VARCHAR2(30) := get_db_current_instance_name;
  v_prod_instance_name     VARCHAR2(30) := get_db_prod_instance_name;
  v_uat_message            VARCHAR2(2000);

BEGIN

  -- Set the email setting variables:
  FOR email_settings IN (
      SELECT DECODE(v_current_instance_name,  -- If not Prod, send to test email
                    v_prod_instance_name,
                      emt_sender_email_address,
                      ese_test_email_account) AS sender_email,
             emt_sender_email_address AS sender_test,
             DECODE(v_current_instance_name,  -- If not Prod, send to test email
                    v_prod_instance_name,
                      emt_recipient_domain,
                      ese_test_email_account) AS recipient_email,
             emt_recipient_domain AS recipient_test,
             ese_mailhost,
             ese_mailport,
             REPLACE(
               emt_subject_text_e||' / '||emt_subject_text_f,
               '<v_position_nmbr>', v_position_nmbr) AS subject,
             REPLACE(
              REPLACE(
                emt_message_text_e||' <BR> <BR>'||emt_message_text_f,
                '<v_employee_name>', TRIM(tips.get_first_last_name(v_employee_pin))),
              '<v_position_nmbr>', v_position_nmbr) AS message,
             ese_test_email_account
        FROM email_settings,
             email_message_text
       WHERE ese_email_id = v_email_id
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
                             ~~~~ END UAT MESSAGE <BR>
                             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<BR>
                             </I><BR><BR>';
           TIPS.SEND_EMAIL
             (email_settings.sender_email,
              email_settings.recipient_email,
              NULL,
              email_settings.subject,
              v_uat_message||email_settings.message,
              email_settings.ese_mailhost,
              email_settings.ese_mailport,
              v_return_message_nmbr);
        ELSE
           TIPS.SEND_EMAIL
             (email_settings.sender_email,
              email_settings.recipient_email,
              NULL,
              email_settings.subject,
              email_settings.message,
              email_settings.ese_mailhost,
              email_settings.ese_mailport,
              v_return_message_nmbr);
        END IF;
   END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    v_return_message_nmbr := SQLCODE;
END; -- Procedure
/

-- Grants for Procedure
GRANT EXECUTE ON send_email_hrsr_exclusion_unit TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_EXCLUSION_UNIT

