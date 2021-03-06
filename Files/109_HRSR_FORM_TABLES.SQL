

CREATE TABLE AH105_XREF_AH027_TH200_FORM
(
    HRSR_REQUEST_CD      VARCHAR2(20) NOT NULL ,
    HRSR_FORM_ID         NUMBER NOT NULL ,
    COMPLETED_RDIMS_NBR  NUMBER(22) NULL ,
    DATE_CREATED_DTE     DATE NULL ,
    DATE_LAST_UPDATE_DTE DATE NULL ,
    USER_LAST_UPDATE_ID  VARCHAR2(30) NULL ,
    DATE_DELETED_DTE     DATE NULL 
);

COMMENT ON TABLE AH105_XREF_AH027_TH200_FORM IS 'Cross reference table between an HRSR request (AH027_HRSR_REQUEST) and a form (TH200_HRSR_FORM).';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.HRSR_REQUEST_CD IS 'Foreign key to AH027_HRSR_REQUEST table. This column will identify the HRSR request code associated with the record.';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.HRSR_FORM_ID IS 'Foreign key to TH200_HRSR_FORM. Identifies the form ID associated with the record. ';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.COMPLETED_RDIMS_NBR IS 'The RDIMS number of the completed form.';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN AH105_XREF_AH027_TH200_FORM.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

CREATE UNIQUE INDEX AH105_PK ON AH105_XREF_AH027_TH200_FORM
(HRSR_REQUEST_CD   ASC,HRSR_FORM_ID   ASC);

CREATE INDEX AH105_IF1 ON AH105_XREF_AH027_TH200_FORM
(HRSR_REQUEST_CD   ASC);

CREATE INDEX AH105_IF2 ON AH105_XREF_AH027_TH200_FORM
(HRSR_FORM_ID   ASC);

CREATE TABLE AH106_XREF_AH027_TH199_DOC
(
    HRSR_REQUEST_CD      VARCHAR2(20) NOT NULL ,
    HRSR_DOCUMENT_ID     NUMBER NOT NULL ,
    COMPLETED_RDIMS_NBR  NUMBER(22) NULL ,
    DATE_CREATED_DTE     DATE NULL ,
    DATE_LAST_UPDATE_DTE DATE NULL ,
    USER_LAST_UPDATE_ID  VARCHAR2(30) NULL ,
    DATE_DELETED_DTE     DATE NULL 
);

COMMENT ON TABLE AH106_XREF_AH027_TH199_DOC IS 'Cross reference table between an HRSR request (AH027_HRSR_REQUEST) and a document (TH199_HRSR_DOCUMENT).';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.HRSR_REQUEST_CD IS 'Foreign key to AH027_HRSR_REQUEST. Identifies the HRSR request number associated with the record.';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.HRSR_DOCUMENT_ID IS 'Foreign key to TH199_HRSR_DOCUMENT. Identifies the document ID associated with the record. ';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.COMPLETED_RDIMS_NBR IS 'The RDIMS number of the completed document';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN AH106_XREF_AH027_TH199_DOC.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

CREATE UNIQUE INDEX AH106_PK ON AH106_XREF_AH027_TH199_DOC
(HRSR_REQUEST_CD   ASC,HRSR_DOCUMENT_ID   ASC);

CREATE INDEX AH106_IF1 ON AH106_XREF_AH027_TH199_DOC
(HRSR_REQUEST_CD   ASC);

CREATE INDEX AH106_IF2 ON AH106_XREF_AH027_TH199_DOC
(HRSR_DOCUMENT_ID   ASC);

CREATE TABLE TH199_HRSR_DOCUMENT
(
    HRSR_DOCUMENT_ID     NUMBER NOT NULL ,
    HRSR_DOCUMENT_ENM    VARCHAR2(50) NOT NULL ,
    HRSR_DOCUMENT_FNM    VARCHAR2(50) NOT NULL ,
    HRSR_DOCUMENT_ETXT   VARCHAR2(250) NULL ,
    HRSR_DOCUMENT_FTXT   VARCHAR2(250) NULL ,
    DATE_CREATED_DTE     DATE NULL ,
    DATE_LAST_UPDATE_DTE DATE NULL ,
    USER_LAST_UPDATE_ID  VARCHAR2(30) NULL ,
    DATE_DELETED_DTE     DATE NULL 
);

COMMENT ON TABLE TH199_HRSR_DOCUMENT IS 'Look up table of the documents that could be associated with an HRSR';

COMMENT ON COLUMN TH199_HRSR_DOCUMENT.HRSR_DOCUMENT_ID IS 'Unique, system generated primary key of the record. ';

COMMENT ON COLUMN TH199_HRSR_DOCUMENT.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN TH199_HRSR_DOCUMENT.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN TH199_HRSR_DOCUMENT.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN TH199_HRSR_DOCUMENT.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

CREATE UNIQUE INDEX TH199_PK ON TH199_HRSR_DOCUMENT
(HRSR_DOCUMENT_ID   ASC);

CREATE UNIQUE INDEX TH199_AK1 ON TH199_HRSR_DOCUMENT
(HRSR_DOCUMENT_ENM   ASC);

CREATE UNIQUE INDEX TH199_AK2 ON TH199_HRSR_DOCUMENT
(HRSR_DOCUMENT_FNM   ASC);

CREATE TABLE TH200_HRSR_FORM
(
    HRSR_FORM_ID         NUMBER NOT NULL ,
    HRSR_FORM_ENM        VARCHAR2(50) NOT NULL ,
    HRSR_FORM_FNM        VARCHAR2(50) NOT NULL ,
    HRSR_FORM_ETXT       VARCHAR2(250) NULL ,
    HRSR_FORM_FTXT       VARCHAR2(250) NULL ,
    HRSR_ENGLISH_FORM_NUM VARCHAR2(100) NULL,
    HRSR_FRENCH_FORM_NUM VARCHAR2(100) NULL,
    HRSR_FORM_LOCATION_ETXT VARCHAR2(100) NULL,
    HRSR_FORM_LOCATION_FTXT VARCHAR2(100) NULL,   
    DATE_CREATED_DTE     DATE NULL ,
    DATE_LAST_UPDATE_DTE DATE NULL ,
    USER_LAST_UPDATE_ID  VARCHAR2(30) NULL ,
    DATE_DELETED_DTE     DATE NULL 
);

COMMENT ON TABLE TH200_HRSR_FORM IS 'Look up table of the forms that could be associated with an HRSR or an HRSR action type.';

COMMENT ON COLUMN TH200_HRSR_FORM.HRSR_FORM_ID IS 'Unique, system generated primary key of the record. ';

COMMENT ON COLUMN TH200_HRSR_FORM.HRSR_FORM_ENM IS 'English name of the form';

COMMENT ON COLUMN TH200_HRSR_FORM.HRSR_FORM_FNM IS 'French name of the form';

COMMENT ON COLUMN TH200_HRSR_FORM.HRSR_FORM_ETXT IS 'English description of the form ';

COMMENT ON COLUMN TH200_HRSR_FORM.HRSR_FORM_FTXT IS 'French description of of the form ';

COMMENT ON COLUMN TH200_HRSR_FORM.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN TH200_HRSR_FORM.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN TH200_HRSR_FORM.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN TH200_HRSR_FORM.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

CREATE UNIQUE INDEX TH200_PK ON TH200_HRSR_FORM
(HRSR_FORM_ID   ASC);

CREATE UNIQUE INDEX TH200_AK1 ON TH200_HRSR_FORM
(HRSR_FORM_ENM   ASC);

CREATE UNIQUE INDEX TH200_AK2 ON TH200_HRSR_FORM
(HRSR_FORM_FNM   ASC);

CREATE TABLE TH201_XREF_TH048_TH200_FORM
(
    ACTION_CD            VARCHAR2(2) NOT NULL ,
    HRSR_FORM_ID         NUMBER NOT NULL ,
    APPLICABLE_IND       NUMBER(1) NOT NULL ,    
    DATE_CREATED_DTE     DATE NULL ,
    DATE_LAST_UPDATE_DTE DATE NULL ,
    USER_LAST_UPDATE_ID  VARCHAR2(30) NULL ,
    DATE_DELETED_DTE     DATE NULL 
);

COMMENT ON TABLE TH201_XREF_TH048_TH200_FORM IS 'Cross reference look up table of the HRSR forms (TH200_HRSR_FORM) associated with an HRSR Action Types (TH048) 
';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.APPLICABLE_IND IS 'An indicator to identify that the Form is required when applicable. This would be a form that is required when certian conditions are met (ex: when a student action is for aboriginal students, there may be documents required that are not for other student actions). 1 = Yes, 0 = No';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.ACTION_CD IS 'Foreign key to the TH048_HRSR_ACTION table. Identifies the action type associated with the record.';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.HRSR_FORM_ID IS 'Foreign key to the TH200_HRSR_DOCUMENT table. Identifies the form associated with the record. ';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.DATE_CREATED_DTE IS 'The date on which the data item was created and became available for use.';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.DATE_LAST_UPDATE_DTE IS 'The date the data item was last updated.';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.USER_LAST_UPDATE_ID IS 'The responsible user that affected the last change of the data record.';

COMMENT ON COLUMN TH201_XREF_TH048_TH200_FORM.DATE_DELETED_DTE IS 'The date from which the data item is no longer allowed to be referenced for any new inserts or updates.
This can only happen for the current day or previous dates.';

CREATE UNIQUE INDEX TH201_PK ON TH201_XREF_TH048_TH200_FORM
(ACTION_CD   ASC,HRSR_FORM_ID   ASC);

CREATE INDEX TH201_IF1 ON TH201_XREF_TH048_TH200_FORM
(ACTION_CD   ASC);

CREATE INDEX TH201_IF2 ON TH201_XREF_TH048_TH200_FORM
(HRSR_FORM_ID   ASC);

ALTER TABLE TH201_XREF_TH048_TH200_FORM
    MODIFY APPLICABLE_IND CONSTRAINT  WHEN_APPLICABLE_IND CHECK (APPLICABLE_IND BETWEEN 0 AND 1);

COMMENT ON COLUMN TH193_CONDITION_OF_EMPLOYMENT.HRSR_DOCUMENT_ID IS 'Foreign key to TH200_HRSR_DOCUMENT table. This will identify the document required for the condtion of employment.';

COMMENT ON TABLE AH100_XREF_AH029_TH193 IS 'Cross reference table between an HRSR Staffing request (AH029_HRSR_STAFFING) and a condition of employment (TH193_CONDITION_OF_EMPLOYMENT)';

ALTER TABLE AH105_XREF_AH027_TH200_FORM
ADD CONSTRAINT  AH105_PK PRIMARY KEY (HRSR_REQUEST_CD,HRSR_FORM_ID);

ALTER TABLE AH106_XREF_AH027_TH199_DOC
ADD CONSTRAINT  AH106_PK PRIMARY KEY (HRSR_REQUEST_CD,HRSR_DOCUMENT_ID);

ALTER TABLE TH199_HRSR_DOCUMENT
ADD CONSTRAINT  TH199_PK PRIMARY KEY (HRSR_DOCUMENT_ID);

ALTER TABLE TH199_HRSR_DOCUMENT
ADD CONSTRAINT  TH199_AK1 UNIQUE (HRSR_DOCUMENT_ENM);

ALTER TABLE TH199_HRSR_DOCUMENT
ADD CONSTRAINT  TH199_AK2 UNIQUE (HRSR_DOCUMENT_FNM);

ALTER TABLE TH200_HRSR_FORM
ADD CONSTRAINT  TH200_PK PRIMARY KEY (HRSR_FORM_ID);

ALTER TABLE TH200_HRSR_FORM
ADD CONSTRAINT  TH200_AK1 UNIQUE (HRSR_FORM_ENM);

ALTER TABLE TH200_HRSR_FORM
ADD CONSTRAINT  TH200_AK2 UNIQUE (HRSR_FORM_FNM);

ALTER TABLE TH201_XREF_TH048_TH200_FORM
ADD CONSTRAINT  TH201_PK PRIMARY KEY (ACTION_CD,HRSR_FORM_ID);

ALTER TABLE AH105_XREF_AH027_TH200_FORM
ADD CONSTRAINT AH105_AH027_FK FOREIGN KEY (HRSR_REQUEST_CD) REFERENCES AH027_HRSR_REQUEST (RQT_HRSR_REQUEST_CD);

ALTER TABLE AH105_XREF_AH027_TH200_FORM
ADD CONSTRAINT AH105_TH200_FK FOREIGN KEY (HRSR_FORM_ID) REFERENCES TH200_HRSR_FORM (HRSR_FORM_ID);

ALTER TABLE AH106_XREF_AH027_TH199_DOC
ADD CONSTRAINT AH106_AH027_FK FOREIGN KEY (HRSR_REQUEST_CD) REFERENCES AH027_HRSR_REQUEST (RQT_HRSR_REQUEST_CD);

ALTER TABLE AH106_XREF_AH027_TH199_DOC
ADD CONSTRAINT AH106_TH199_FK FOREIGN KEY (HRSR_DOCUMENT_ID) REFERENCES TH199_HRSR_DOCUMENT (HRSR_DOCUMENT_ID);

ALTER TABLE TH201_XREF_TH048_TH200_FORM
ADD CONSTRAINT TH201_TH048_FK FOREIGN KEY (ACTION_CD) REFERENCES TH048_HRSR_ACTION (ACT_ACTION_CD);

ALTER TABLE TH201_XREF_TH048_TH200_FORM
ADD CONSTRAINT TH201_TH200_FK FOREIGN KEY (HRSR_FORM_ID) REFERENCES TH200_HRSR_FORM (HRSR_FORM_ID);

ALTER TABLE TH193_CONDITION_OF_EMPLOYMENT
ADD CONSTRAINT TH193_TH199_FK FOREIGN KEY (HRSR_DOCUMENT_ID) REFERENCES TH199_HRSR_DOCUMENT (HRSR_DOCUMENT_ID);

CREATE OR REPLACE PUBLIC SYNONYM TH199_HRSR_DOCUMENT FOR TIPS.TH199_HRSR_DOCUMENT;
CREATE OR REPLACE PUBLIC SYNONYM TH200_HRSR_FORM FOR TH200_HRSR_FORM;
CREATE OR REPLACE PUBLIC SYNONYM TH201_XREF_TH048_TH200_FORM FOR TH201_XREF_TH048_TH200_FORM;
CREATE OR REPLACE PUBLIC SYNONYM AH106_XREF_AH027_TH199_DOC FOR AH106_XREF_AH027_TH199_DOC;
CREATE OR REPLACE PUBLIC SYNONYM AH105_XREF_AH027_TH200_FORM FOR AH105_XREF_AH027_TH200_FORM;

GRANT SELECT ON TH199_HRSR_DOCUMENT TO tipsuser;
GRANT SELECT ON TH200_HRSR_FORM TO tipsuser;
GRANT SELECT ON TH201_XREF_TH048_TH200_FORM TO tipsuser;
GRANT SELECT ON AH106_XREF_AH027_TH199_DOC TO tipsuser;
GRANT SELECT ON AH105_XREF_AH027_TH200_FORM TO tipsuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TH199_HRSR_DOCUMENT TO everything_in_tips;
GRANT SELECT, INSERT, UPDATE, DELETE ON TH200_HRSR_FORM TO everything_in_tips;
GRANT SELECT, INSERT, UPDATE, DELETE ON TH201_XREF_TH048_TH200_FORM TO everything_in_tips;
GRANT SELECT, INSERT, UPDATE, DELETE ON AH106_XREF_AH027_TH199_DOC TO everything_in_tips;
GRANT SELECT, INSERT, UPDATE, DELETE ON AH105_XREF_AH027_TH200_FORM TO everything_in_tips;















