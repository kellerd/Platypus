-- Start of DDL Script for Function TIPS.FN_ACCENT_INSENSITIVE
-- Generated 2019-07-17 11:57:18 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_accent_insensitive
 ( V_VALUE      VARCHAR2
 )
RETURN VARCHAR2 DETERMINISTIC
 IS
--
-- Created by:  D. Keller 2019
--
-- Purpose: This function is used to convert a string to case insensitive,
--          accent insensitive for searching
--          Alternatives are using the CONVERT FUNCTION
--
--           Returns: Kéller  => keller
--
--
-- MODIFICATION HISTORY
-- Person    Date         Comments
-- --------- -----------  ------------------------------------------------------
-- D. Keller July 2019    Initial Version
-- D. Keller July 16 2019 NLSSORT adds a nullbyte to the value. strip the nullbyte

BEGIN


    RETURN utl_raw.cast_to_varchar2(SUBSTR(NLSSORT(V_VALUE, 'nls_sort=binary_ai'),1,
                                    LENGTH(NLSSORT(V_VALUE, 'nls_sort=binary_ai'))-2 ));

END;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_accent_insensitive 
   FOR tips.fn_accent_insensitive
/   
-- Grants for Function
GRANT EXECUTE ON fn_accent_insensitive TO tipsuser
/
GRANT EXECUTE ON fn_accent_insensitive TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_ACCENT_INSENSITIVE

