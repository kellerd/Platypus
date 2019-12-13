-- Start of DDL Script for Function TIPS.FN_GET_HRSR_ERROR_MESSAGE_ETXT
-- Generated 2019-07-15 2:17:45 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_hrsr_error_message_etxt(
  v_error_message_num  IN th191_hrsr_error_message.hrsr_error_message_num%TYPE)
  RETURN th191_hrsr_error_message.hrsr_error_message_etxt%TYPE
IS
--
-- Created by: Jennifer Hynes, Jul 15, 2019
--
-- Purpose: Returns the English error message for the error message nmbr passed
--          in.
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--

BEGIN
  FOR error_message_rec IN (
      SELECT hrsr_error_message_etxt
        FROM th191_hrsr_error_message
       WHERE hrsr_error_message_num = v_error_message_num
  ) LOOP
    RETURN error_message_rec.hrsr_error_message_etxt;
  END LOOP;
  -- If there is no matching error message, return Message Unavailable
  RETURN('Error: Message unavailable');
END fn_get_hrsr_error_message_etxt;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_get_hrsr_error_message_etxt 
  FOR tips.fn_get_hrsr_error_message_etxt
  /
  
GRANT EXECUTE ON fn_get_hrsr_error_message_etxt TO tipsuser;
GRANT EXECUTE ON fn_get_hrsr_error_message_etxt TO everything_in_tips;  


-- End of DDL Script for Function TIPS.FN_GET_HRSR_ERROR_MESSAGE_ETXT

