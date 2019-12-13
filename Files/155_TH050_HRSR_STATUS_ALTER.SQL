
ALTER TABLE TH050_HRSR_STATUS
    ADD (CONFIRM_DIALOGUE_ETXT VARCHAR2(1000));

ALTER TABLE TH050_HRSR_STATUS
    ADD (CONFIRM_DIALOGUE_FTXT VARCHAR2(1000));

ALTER TABLE TH050_HRSR_STATUS
    ADD (DATE_CREATED_DTE DATE);

ALTER TABLE TH050_HRSR_STATUS
    ADD (DATE_LAST_UPDATE_DTE DATE);

ALTER TABLE TH050_HRSR_STATUS
    ADD (USER_LAST_UPDATE_ID VARCHAR2(30));

ALTER TABLE TH050_HRSR_STATUS
    ADD (DATE_DELETED_DTE DATE);

COMMENT ON COLUMN TH050_HRSR_STATUS.CONFIRM_DIALOGUE_ETXT IS 'English confirmation dialogue that will be displayed in a pop up prior to the status being set in the HRSR.';

COMMENT ON COLUMN TH050_HRSR_STATUS.CONFIRM_DIALOGUE_FTXT IS 'French confirmation dialogue that will be displayed in a pop up prior to the status being set in the HRSR.';

COMMENT ON COLUMN TH050_HRSR_STATUS.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN TH050_HRSR_STATUS.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN TH050_HRSR_STATUS.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN TH050_HRSR_STATUS.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

