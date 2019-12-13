
CREATE OR REPLACE TRIGGER ah096_tg1_buid_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON AH096_HRSR_USER_SEARCH
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- WRITTEN BY: Jennifer Hynes, January 16, 2017
--             HRSR 2.0 
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--
   v_audit_id            audit_master.aum_audit_row_id%TYPE;
   v_event_id            audit_master.aum_event_id%TYPE;
   v_event_ind           audit_master.aum_event_ind%TYPE;
   v_event_datetime      audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count               INTEGER;
   
   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;
      
BEGIN

  IF UPDATING THEN
      v_event_ind := 'U';
      v_audit_id := :OLD.AUDIT_ROW_ID;
      :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
      :NEW.USER_LAST_UPDATE_ID := v_user_id;

   ELSIF DELETING THEN
      v_event_ind := 'D';
      v_audit_id := :OLD.AUDIT_ROW_ID;

   ELSE  -- INSERTING

      SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0'),
             ah096_search_id_seq.NEXTVAL 
        INTO :NEW.AUDIT_ROW_ID,
             :NEW.SEARCH_ID
        FROM DUAL;

      v_event_ind := 'I';
      v_audit_id := :NEW.AUDIT_ROW_ID;
      
      :NEW.DATE_CREATED_DTE := SYSDATE;   
      :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
      :NEW.USER_LAST_UPDATE_ID := v_user_id;
          
   END IF;

   SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
     INTO v_event_id
     FROM dual;
    -- UPDATE the audit_master table using the audit_master_update procedure
    AUDIT_MASTER_UPDATE (v_event_id,
                         v_audit_id,
                         v_event_datetime,
                         v_event_ind,
                         'AH096_HRSR_USER_SEARCH' );
   -- WRITE a row to the audit details table for each column changed.
   AUDIT_DETAILS_UPDATE (v_event_id,
                         v_audit_id,
                         v_event_datetime,
                         'USER_ID',
                         :OLD.USER_ID,
                         :NEW.USER_ID);
   AUDIT_DETAILS_UPDATE (v_event_id,
                         v_audit_id,
                         v_event_datetime,
                         'SEARCH_NAME_TXT',
                         :OLD.SEARCH_NAME_TXT,
                         :NEW.SEARCH_NAME_TXT);
   AUDIT_DETAILS_UPDATE (v_event_id,
                         v_audit_id,
                         v_event_datetime,
                         'USER_DEFAULT_SEARCH_IND',
                         TO_CHAR(:OLD.USER_DEFAULT_SEARCH_IND),
                         TO_CHAR(:NEW.USER_DEFAULT_SEARCH_IND));
  -- Cleanup the audit_master table.  Delete the audit master record
  -- if no changes have actually been made to the audit details.
  SELECT COUNT(*)
    INTO v_count
    FROM audit_details
   WHERE aud_event_id = v_event_id;
  IF v_count = 0 THEN
     DELETE FROM audit_master
      WHERE aum_event_id = v_event_id;
  END IF;
END;
/



