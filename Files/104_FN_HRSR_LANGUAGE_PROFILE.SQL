-- Start of DDL Script for Function TIPS.FN_HRSR_LANGUAGE_PROFILE
-- Generated 6-Aug-19 8:03:34 from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_hrsr_language_profile
  ( v_employee_pin    language_evaluation_results.ler_pin%TYPE
  )
  RETURN  VARCHAR2 IS
--
-- Purpose: Function to return if the employee language profile.
--          Developed for HRSR_CREATE_STAFFING_ACTION procedure.
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_first_language    persons.per_first_lang_code%TYPE;
   v_language_profile  VARCHAR2(3);
   v_reading_profile   VARCHAR2(1);
   v_writing_profile   VARCHAR2(1);
   v_oral_profile      VARCHAR2(1);

BEGIN

  SELECT NVL(MAX(per_first_lang_code),1) -- Default NULL to English
    INTO v_first_language
    FROM persons a
   WHERE a.per_pin = v_employee_pin
     AND a.per_type_code = (SELECT MIN(b.per_type_code)
                              FROM persons b
                             WHERE b.per_pin = a.per_pin
                              AND b.per_pin = v_employee_pin) ;

  SELECT REPLACE(NVL(MAX(ler_language_rating_ind),' '),'/',' ')
    INTO v_reading_profile
    FROM language_evaluation_results reading
   WHERE reading.ler_pin = v_employee_pin
     AND reading.ler_language_ind  != v_first_language
     AND reading.ler_language_factor_ind = '1'
     AND NVL(reading.ler_expiry_date, SYSDATE + 1) > SYSDATE
     AND NVL(reading.ler_expiry_date, '31-DEC-2099') =
         (SELECT MAX(NVL(ler_expiry_date, '31-DEC-2099'))
            FROM language_evaluation_results max_ler
           WHERE max_ler.ler_pin = reading.ler_pin
             AND max_ler.ler_language_ind = reading.ler_language_ind
             AND max_ler.ler_language_factor_ind =
                 reading.ler_language_factor_ind);

  SELECT REPLACE(NVL(MAX(ler_language_rating_ind),' '),'/',' ')
    INTO v_writing_profile
    FROM language_evaluation_results writing
   WHERE writing.ler_pin = v_employee_pin
     AND writing.ler_language_ind  != v_first_language
     AND writing.ler_language_factor_ind = '2'
     AND NVL(writing.ler_expiry_date, SYSDATE + 1) > SYSDATE
     AND NVL(writing.ler_expiry_date, '31-DEC-2099') =
         (SELECT MAX(NVL(ler_expiry_date, '31-DEC-2099'))
            FROM language_evaluation_results max_ler
           WHERE max_ler.ler_pin = writing.ler_pin
             AND max_ler.ler_language_ind = writing.ler_language_ind
             AND max_ler.ler_language_factor_ind =
                 writing.ler_language_factor_ind);

  SELECT REPLACE(NVL(MAX(ler_language_rating_ind),' '),'/',' ')
    INTO v_oral_profile
    FROM language_evaluation_results oral
   WHERE oral.ler_pin = v_employee_pin
     AND oral.ler_language_ind != v_first_language
     AND oral.ler_language_factor_ind = '3'
     AND NVL(oral.ler_expiry_date, SYSDATE + 1) > SYSDATE
     AND NVL(oral.ler_expiry_date, '31-DEC-2099') =
         (SELECT MAX(NVL(ler_expiry_date, '31-DEC-2099'))
            FROM language_evaluation_results max_ler
           WHERE max_ler.ler_pin = oral.ler_pin
             AND max_ler.ler_language_ind = oral.ler_language_ind
             AND max_ler.ler_language_factor_ind =
                 oral.ler_language_factor_ind);


   v_language_profile := NVL(v_reading_profile,' ')||
                         NVL(v_writing_profile,' ')||
                         NVL(v_oral_profile,' ');

   RETURN v_language_profile;


EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL  ;
END;
/



-- End of DDL Script for Function TIPS.FN_HRSR_LANGUAGE_PROFILE

