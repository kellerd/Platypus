
ALTER TABLE TH048_HRSR_ACTION
    ADD (ACT_APPROVER_DISCLAIMER_ETXT CLOB );

ALTER TABLE TH048_HRSR_ACTION
    ADD (ACT_APPROVER_DISCLAIMER_FTXT CLOB );

COMMENT ON COLUMN TH048_HRSR_ACTION.ACT_APPROVER_DISCLAIMER_ETXT IS 'The English disclaimer text that will be displayed to the Approver of an HRSR process for the action. 

A disclaimer is generally any statement intended to specify or delimit the scope of rights and obligations that may be exercised and enforced by parties in a legally recognized relationship.  

The continuation of the HRSR action will be considered a confirmation of the terms of the disclaimer displayed by the application.';

COMMENT ON COLUMN TH048_HRSR_ACTION.ACT_APPROVER_DISCLAIMER_FTXT IS 'The French disclaimer text that will be displayed to the Approver of an HRSR process for the action. 

A disclaimer is generally any statement intended to specify or delimit the scope of rights and obligations that may be exercised and enforced by parties in a legally recognized relationship.  

The continuation of the HRSR action will be considered a confirmation of the terms of the disclaimer displayed by the application.';




ALTER TABLE TH048_HRSR_ACTION MODIFY(ACT_ACTION_DESCRIPTION_ETXT VARCHAR2(2000) );


ALTER TABLE TH048_HRSR_ACTION MODIFY(ACT_ACTION_DESCRIPTION_FTXT VARCHAR2(2000) );

