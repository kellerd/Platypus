-- Start of DDL Script for Function TIPS.FN_GET_PREVIOUS_GEO_PROVINCE
-- Generated 2019-05-18 7:27:30 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_previous_geo_province
  ( v_employee_pin                assignments.asn_employee_pin%TYPE,
    v_new_assignment_start_dte    assignments.asn_effective_start_date%TYPE
  )
  RETURN  geographic_locations.gel_province%TYPE IS
--
-- Purpose: Function to return the Province for the previous assignment to
--          the HRSR application.
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_province_cd  geographic_locations.gel_province%TYPE;

BEGIN
  FOR previous_assignment_rec IN (
       SELECT *
         FROM assignments
        WHERE asn_employee_pin = v_employee_pin
          AND asn_effective_start_date < v_new_assignment_start_dte
        ORDER BY NVL(asn_effective_end_date,
                 TO_DATE('31-DEC-2099','DD-MON-YYYY')) DESC
  ) LOOP

    SELECT MAX(gel_province)
      INTO v_province_cd
      FROM geographic_locations
     WHERE previous_assignment_rec.asn_geo_code =
           gel_geo_province_code||gel_geo_detail_code;

   RETURN v_province_cd;

   END LOOP;

   RETURN NULL;
EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL  ;
END;
/

GRANT EXECUTE ON FN_GET_PREVIOUS_GEO_PROVINCE TO tipsuser;
GRANT EXECUTE ON FN_GET_PREVIOUS_GEO_PROVINCE TO everything_in_tips;


-- End of DDL Script for Function TIPS.FN_GET_PREVIOUS_GEO_PROVINCE

