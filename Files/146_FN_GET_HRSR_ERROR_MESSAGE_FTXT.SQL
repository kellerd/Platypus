-- Start of DDL Script for Function TIPS.FN_GET_HRSR_ERROR_MESSAGE_FTXT
-- Generated 2019-07-15 2:15:47 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_hrsr_error_message_ftxt(
  v_error_message_num  IN th191_hrsr_error_message.hrsr_error_message_num%TYPE)
  RETURN th191_hrsr_error_message.hrsr_error_message_ftxt%TYPE
IS
--
-- Created by: Jennifer Hynes, Jul 15, 2019
--
-- Purpose: Returns the French error message for the error message nmbr passed
--          in.
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--

BEGIN
  FOR error_message_rec IN (
      SELECT hrsr_error_message_ftxt
        FROM th191_hrsr_error_message
       WHERE hrsr_error_message_num = v_error_message_num
  ) LOOP
    RETURN error_message_rec.hrsr_error_message_ftxt;
  END LOOP;
  -- If there is no matching error message, return Message Unavailable
  RETURN('Erreur: message indisponible');
END fn_get_hrsr_error_message_ftxt;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_get_hrsr_error_message_ftxt 
  FOR tips.fn_get_hrsr_error_message_ftxt
  /
  
GRANT EXECUTE ON fn_get_hrsr_error_message_ftxt TO tipsuser;
GRANT EXECUTE ON fn_get_hrsr_error_message_ftxt TO everything_in_tips;  


-- End of DDL Script for Function TIPS.FN_GET_HRSR_ERROR_MESSAGE_FTXT

