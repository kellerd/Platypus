
ALTER TABLE AH027_HRSR_REQUEST
    ADD (RQT_ALT_ADVISOR_PIN VARCHAR2(9));

COMMENT ON COLUMN AH027_HRSR_REQUEST.RQT_ALT_ADVISOR_PIN IS 'Alternate HR User that can be assigned to process the HRSR. (LEGACY column)';

