
CREATE TABLE AH109_HRSR_CANDIDATE_SIN
(
    HRSR_REQUEST_CD      VARCHAR2(20) NOT NULL ,
    CANDIDATE_SOCIAL_INSURANCE_NUM VARCHAR2(60) NOT NULL ,
    DATE_CREATED_DTE     DATE NULL ,
    DATE_LAST_UPDATE_DTE DATE NULL ,
    USER_LAST_UPDATE_ID  VARCHAR2(30) NULL ,
    DATE_DELETED_DTE     DATE NULL 
);

COMMENT ON TABLE AH109_HRSR_CANDIDATE_SIN IS 'A table to temporarily store the social insurance number (SIN) of an HRSR candidate, who is not in the TIPS database with a valid PRI. This information will be sent to the HR advisor who will then use this data to create a PRI for the candidate. After the PRI is created, this record for the HRSR will be deleted from the table. ';

COMMENT ON COLUMN AH109_HRSR_CANDIDATE_SIN.HRSR_REQUEST_CD IS 'Foreign key to AH029_HRSR_STAFFING. Represents the Human Resource Staffing Request (HRSR code).';

COMMENT ON COLUMN AH109_HRSR_CANDIDATE_SIN.CANDIDATE_SOCIAL_INSURANCE_NUM IS 'Social insurance number (SIN) of the candidate. The Social Insurance Number (SIN) is a nine-digit number that you need to work in Canada or to have access to government programs and benefits';

COMMENT ON COLUMN AH109_HRSR_CANDIDATE_SIN.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN AH109_HRSR_CANDIDATE_SIN.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN AH109_HRSR_CANDIDATE_SIN.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN AH109_HRSR_CANDIDATE_SIN.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

CREATE UNIQUE INDEX AH109_PK ON AH109_HRSR_CANDIDATE_SIN
(HRSR_REQUEST_CD   ASC);

ALTER TABLE AH109_HRSR_CANDIDATE_SIN
ADD CONSTRAINT  AH109_PK PRIMARY KEY (HRSR_REQUEST_CD);

ALTER TABLE AH109_HRSR_CANDIDATE_SIN
ADD CONSTRAINT AH109_AH029_FK FOREIGN KEY (HRSR_REQUEST_CD) REFERENCES AH029_HRSR_STAFFING (STF_HRSR_REQUEST_CD);

CREATE OR REPLACE PUBLIC SYNONYM AH109_HRSR_CANDIDATE_SIN FOR TIPS.AH109_HRSR_CANDIDATE_SIN;
GRANT SELECT ON AH109_HRSR_CANDIDATE_SIN TO tipsuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON AH109_HRSR_CANDIDATE_SIN TO everything_in_tips;

