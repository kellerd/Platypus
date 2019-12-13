-- Start of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_TAP_PHANT_POS
-- Generated 2019-10-04 2:03:30 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE send_email_hrsr_tap_phant_pos
 ( v_position_nmbr       ah012_position_profile_detail.pop_position_nmbr%TYPE,
   v_delegation_cd       th022_profile_code.pro_delegation_authority_cd%TYPE,
   v_profile_start_dte   ah012_position_profile_detail.pop_profile_start_dte%TYPE,
   v_sender_user_id      users.usr_user_id%TYPE,
   v_return_message_nmbr OUT NUMBER )
   IS
--
-- Created by: Jennifer Hynes, May 2007
--
-- Purpose: This procedure will create and send an email to Clasification to
--          advise that a phantom position has been created that requires
--          Staffing and/or Financial Delegation.
--
--          Note: choosing Staffing Delegation will mean position will get both
--          Staffing and Financial Delegation, choosing Financial Delegation
--          will only receive Financial.
--
--          Procedure to be used by the Training and Profiles application (TAP)
--
--          * 020   TAP     Phantom Position Delegation Required
--
--          Requirements as per change requests STAFFING-01230, TMP_ASSGT-01229
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  09-DEC-10  CSA_DEC-01579: Call functions to dynamically determine
--                       if database instance is a Prod copy.
--
-- Hynes, J.  06-JUL-09  PR#317281: Corrected issue with the sender and cc email
--
-- Hynes, J.  03-MAR-09  TIPS_GLOB-01365: Added call to GET_SMTP_EMAIL_ADDRESS
--                       to determine the email address.
--
-- Hynes, J.  29-APR-08  TMP_ASSGT-01318: Added code so that deleted profiles
--                       are not picked up.
--
  v_current_instance_name  VARCHAR2(30) := get_db_current_instance_name;
  v_prod_instance_name     VARCHAR2(30) := get_db_prod_instance_name;
  v_profile_desc_e         VARCHAR2(500);
  v_profile_desc_f         VARCHAR2(500);
  v_uat_message            VARCHAR2(4000);

BEGIN

  -- Build Profile description list:
  FOR profile_desc_rec IN (
      SELECT pro_profile_name_enm,
             pro_profile_name_fnm
        FROM th022_profile_code
       WHERE (pro_delegation_authority_cd = 'FIN'  -- Financial will always be
                                                   -- granted.
              OR pro_delegation_authority_cd = v_delegation_cd)
         AND v_profile_start_dte BETWEEN pro_effective_start_dte AND
             NVL(pro_effective_end_dte,v_profile_start_dte+1)
         AND pro_date_delete_dte IS NULL
  ) LOOP
    v_profile_desc_e := profile_desc_rec.pro_profile_name_enm||'<BR>'||
                        v_profile_desc_e;
    v_profile_desc_f := profile_desc_rec.pro_profile_name_fnm||'<BR>'||
                        v_profile_desc_f;
  END LOOP;

  -- Set the email setting variables:
  FOR email_settings IN (
      SELECT emt_sender_email_address AS sender_email,
             emt_sender_email_address AS sender_test,
             DECODE(v_current_instance_name,  -- If not Prod, send to test email
               v_prod_instance_name, emt_recipient_domain,
                       ese_test_email_account) AS recipient_email,
             emt_recipient_domain AS recipient_test,
             DECODE(emt_cc_email_address, NULL, NULL, -- no cc if cc is null
               DECODE(v_current_instance_name,  -- If not Prod, send to test email
                      v_prod_instance_name,
                        emt_cc_email_address,
                        ese_test_email_account)) AS cc_email,
             emt_cc_email_address AS cc_test,
             ese_mailhost,
             ese_mailport,
             REPLACE(
               emt_subject_text_e||' / '||emt_subject_text_f,
               '<v_position_nmbr>',v_position_nmbr) AS subject,
             REPLACE(
               REPLACE(
               REPLACE(
               REPLACE(
                 emt_message_text_e||'<BR><BR>'||emt_message_text_f,
                 '<v_position_nmbr>',v_position_nmbr),
                 '<v_profile_desc_e>',v_profile_desc_e),
                 '<v_profile_desc_f>',v_profile_desc_f),
                 '<v_profile_start_dte>',TO_CHAR(v_profile_start_dte,'DD-MON-YY'))
                AS message
           FROM email_settings,
                email_message_text
          WHERE ese_email_id = '020'
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
EXCEPTION
 WHEN utl_smtp.Transient_Error OR
      utl_smtp.Permanent_Error THEN
      v_return_message_nmbr := 999;
 WHEN OTHERS THEN
      v_return_message_nmbr := 999;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM SEND_EMAIL_HRSR_TAP_PHANT_POS
  FOR TIPS.SEND_EMAIL_HRSR_TAP_PHANT_POS
/

GRANT EXECUTE ON SEND_EMAIL_HRSR_TAP_PHANT_POS TO TIPSUSER
/

GRANT EXECUTE ON SEND_EMAIL_HRSR_TAP_PHANT_POS TO EVERYTHING_IN_TIPS
/
  

-- End of DDL Script for Procedure TIPS.SEND_EMAIL_HRSR_TAP_PHANT_POS

