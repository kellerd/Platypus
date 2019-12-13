-- Start of DDL Script for Function TIPS.FN_MEETS_LANGUAGE_PROFILE
-- Generated 2019-09-26 12:23:32 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_meets_language_profile
  ( v_employee_pin    language_evaluation_results.ler_pin%TYPE,
    v_position_nmbr   linguistic_profiles.lpr_position_nmbr%TYPE,
    v_hrsr_request_cd ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE
  )
  RETURN  INTEGER IS
--
-- Purpose: Function to return if the candidate / employee meets the language
--          profile of the position.
--
--          An employee will have either a French or English profile stored in
--          LANGUAGE_EVALUATION_RESULTS, except for a small group who may have
--          both profiles, but they are all E / Exempt.
--
--          Profile values (high to low):
--          E = Exempt
--          P = Professional skills
--          C = Highest LEVEL
--          B = Average level
--
--          Return Values:
--          NULL = No position profile required
--          0 = Success, Employee meets the position profile
--          1 = Warning, Employee does not have a profile, but position does
--          2 = Warning, Employee does not meet the position profile
--
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_language_profile  VARCHAR2(3);
   v_reading_profile   VARCHAR2(1);
   v_writing_profile   VARCHAR2(1);
   v_oral_profile      VARCHAR2(1);
   v_lang_cd           VARCHAR2(1);

BEGIN

  -- Check the candidate's first official language:
  SELECT NVL(NVL(MAX(per_first_lang_code),
                 MAX(stf_preferred_language_cd)),1) -- default NULL to English
    INTO v_lang_cd
    FROM persons,
         ah029_hrsr_staffing
   WHERE per_pin = v_employee_pin
     AND stf_hrsr_request_cd = v_hrsr_request_cd;

  -- Check the position to see if it's bilingual and get the language profile
  -- associated with the language other than the first official language of the
  -- candidate.  Ex: If candidate is English, get position French profile:
  FOR pos_profile_rec IN (
      SELECT CASE
              WHEN v_lang_cd = '1' THEN lpr_french_read
              WHEN v_lang_cd = '2' THEN lpr_english_read
              END AS read_txt,
             CASE
              WHEN v_lang_cd = '1' THEN lpr_french_write
              WHEN v_lang_cd = '2' THEN lpr_english_write
              END AS write_txt,
             CASE
              WHEN v_lang_cd = '1' THEN lpr_french_oral
              WHEN v_lang_cd = '2' THEN lpr_english_oral
              END AS oral_txt
        FROM linguistic_profiles
       WHERE lpr_position_nmbr = v_position_nmbr
         AND lpr_status_ind = '1' -- Current
         AND lpr_language_requirement_ind = '1' -- Bilingual
  ) LOOP

  -- Check HRSR for the new candidate's profile, or updated profile for an
  -- employee:
  IF v_hrsr_request_cd IS NOT NULL THEN
     SELECT SUBSTR(MAX(stf_sle_result_txt),1,1),
            SUBSTR(MAX(stf_sle_result_txt),2,1),
            SUBSTR(MAX(stf_sle_result_txt),3,1)
       INTO v_reading_profile,
            v_writing_profile,
            v_oral_profile
       FROM ah029_hrsr_staffing
      WHERE stf_hrsr_request_cd = v_hrsr_request_cd;
  END IF;

  -- Check the Candiate's profile in TIPS for each of the tests; Reading,
  -- Writing and Oral.

  -- Reading
  SELECT MAX(ler_language_rating_ind)
    INTO v_reading_profile
    FROM language_evaluation_results reading
   WHERE reading.ler_pin = v_employee_pin
     AND reading.ler_language_ind != v_lang_cd
     AND v_reading_profile IS NULL
     AND reading.ler_language_factor_ind = '1'
     AND NVL(reading.ler_expiry_date, '31-DEC-2099') =
         (SELECT NVL(MAX(ler_expiry_date), '31-DEC-2099')
            FROM language_evaluation_results max_ler
           WHERE max_ler.ler_pin = reading.ler_pin
             AND max_ler.ler_language_ind = reading.ler_language_ind
             AND max_ler.ler_language_factor_ind =
                 reading.ler_language_factor_ind);

  -- Writing
  SELECT MAX(ler_language_rating_ind)
    INTO v_writing_profile
    FROM language_evaluation_results writing
   WHERE writing.ler_pin = v_employee_pin
     AND writing.ler_language_ind != v_lang_cd
     AND v_writing_profile IS NULL
     AND writing.ler_language_factor_ind = '2'
     AND NVL(writing.ler_expiry_date, '31-DEC-2099') =
         (SELECT NVL(MAX(ler_expiry_date), '31-DEC-2099')
            FROM language_evaluation_results max_ler
           WHERE max_ler.ler_pin = writing.ler_pin
             AND max_ler.ler_language_ind = writing.ler_language_ind
             AND max_ler.ler_language_factor_ind =
                 writing.ler_language_factor_ind);

  -- Oral
  SELECT MAX(ler_language_rating_ind)
    INTO v_oral_profile
    FROM language_evaluation_results oral
   WHERE oral.ler_pin = v_employee_pin
     AND oral.ler_language_ind != v_lang_cd
     AND v_oral_profile IS NULL
     AND oral.ler_language_factor_ind = '3'
     AND NVL(oral.ler_expiry_date, '31-DEC-2099') =
         (SELECT NVL(MAX(ler_expiry_date), '31-DEC-2099')
            FROM language_evaluation_results max_ler
           WHERE max_ler.ler_pin = oral.ler_pin
             AND max_ler.ler_language_ind = oral.ler_language_ind
             AND max_ler.ler_language_factor_ind =
                 oral.ler_language_factor_ind);

    -- Check the Position profile against the Employee Profile:

    -- If position has a profile, but employee / candidate does not have a
    -- profile or has a partial profile, then return error message:
    IF v_reading_profile||v_writing_profile||v_oral_profile IS NULL THEN
       RETURN 1;
    ELSIF pos_profile_rec.read_txt IS NOT NULL AND
       v_reading_profile IS NULL THEN
       RETURN 1;
    ELSIF pos_profile_rec.write_txt IS NOT NULL AND
       v_writing_profile IS NULL THEN
       RETURN 1;
    ELSIF pos_profile_rec.oral_txt IS NOT NULL AND
       v_oral_profile IS NULL THEN
       RETURN 1;
    END IF;

    -- READING profile: Check if candiate passes
    IF pos_profile_rec.read_txt = 'E' AND     -- Exempt
       v_reading_profile NOT IN ('E') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.read_txt = 'P' AND  -- Professional
       v_reading_profile NOT IN ('E','P') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.read_txt = 'C' AND  -- Highest level
       v_reading_profile NOT IN ('E','P','C') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.read_txt = 'B' AND  -- Average level
       v_reading_profile NOT IN ('E','P','C','B') THEN
       -- Does not meet, return warning:
       RETURN 2;
    END IF;

    -- WRITING profile: Check if candiate passes
    IF pos_profile_rec.write_txt = 'E' AND     -- Exempt
       v_writing_profile NOT IN ('E') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.write_txt = 'P' AND  -- Professional
       v_writing_profile NOT IN ('E','P') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.write_txt = 'C' AND  -- Highest level
       v_writing_profile NOT IN ('E','P','C') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.write_txt = 'B' AND  -- Average level
       v_writing_profile NOT IN ('E','P','C','B') THEN
       -- Does not meet, return warning:
       RETURN 2;
    END IF;

    -- ORAL profile: Check if candiate passes
    IF pos_profile_rec.oral_txt = 'E' AND     -- Exempt
       v_oral_profile NOT IN ('E') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.oral_txt = 'P' AND  -- Professional
       v_oral_profile NOT IN ('E','P') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.oral_txt = 'C' AND  -- Highest level
       v_oral_profile NOT IN ('E','P','C') THEN
       -- Does not meet, return warning:
       RETURN 2;
    ELSIF pos_profile_rec.oral_txt = 'B' AND  -- Average level
       v_oral_profile NOT IN ('E','P','C','B') THEN
       -- Does not meet, return warning:
       RETURN 2;
    END IF;

    RETURN 0; -- Success, meets language profile

  END LOOP;

  -- No position language profile fround.
  RETURN NULL;


EXCEPTION
   WHEN OTHERS THEN
       RETURN 999;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_meets_language_profile 
  FOR tips.fn_meets_language_profile
/
  

-- Grants for Function
GRANT EXECUTE ON fn_meets_language_profile TO tipsuser
/
GRANT EXECUTE ON fn_meets_language_profile TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_MEETS_LANGUAGE_PROFILE

