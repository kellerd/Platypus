-- Start of DDL Script for Function TIPS.FN_GET_HRSR_ERROR_MESSAGE_TXT
-- Generated 2019-04-30 2:01:27 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_hrsr_error_message_txt
  ( v_error_message_num   th191_hrsr_error_message.hrsr_error_message_num%TYPE,
    v_language_ind        INTEGER
  )
  RETURN  th191_hrsr_error_message.hrsr_error_message_etxt%TYPE IS
--
-- Purpose: Function to return the English or French error message to the
--          HRSR application.
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------

BEGIN
  FOR error_message_rec IN (
       SELECT *
         FROM th191_hrsr_error_message
        WHERE hrsr_error_message_num = v_error_message_num
  ) LOOP

    IF v_language_ind = 1 THEN
       -- Return French message
       RETURN error_message_rec.hrsr_error_message_ftxt;
    ELSE
       -- Return English message
       RETURN error_message_rec.hrsr_error_message_etxt;
    END IF;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
       RETURN 'Unknown Error' ;
END;
/

-- Grants for Function
GRANT EXECUTE ON fn_get_hrsr_error_message_txt TO tipsuser
/
GRANT EXECUTE ON fn_get_hrsr_error_message_txt TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_GET_HRSR_ERROR_MESSAGE_TXT

