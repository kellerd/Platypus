

ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_TI_PROFILE_CD VARCHAR2(1));
    
COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_TI_PROFILE_CD IS 'Foreign key to TH197_TI_PROFILE. Unique code identifying the TI (TECHNICAL INSPECTION) profile code for the HRSR application. ';
  

ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_ALL_CONDITIONS_MET_IND NUMBER(1));
    
COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_ALL_CONDITIONS_MET_IND IS 'Identifies if all the conditons of the HRSR are met by the candidate. Conditons are in AH100_XREF_AH029_TH193 and in the HRSR CUSTOM CONDITON tables. Possible values are 1 = Yes, 0 = No, NULL = Unknown';
   
    
ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_DATE_CANDIDATE_BIRTH_DTE DATE);

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_DATE_CANDIDATE_BIRTH_DTE IS 'Date of birth for the candidate. ';

ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_CANDIDATE_INITIAL_NAME_TXT VARCHAR2(2));

ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_PREFERRED_LANGUAGE_CD VARCHAR(1));

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_CANDIDATE_INITIAL_NAME_TXT IS 'Candidate initials. Used to create the PERSONS record for new candidate. ';

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_PREFERRED_LANGUAGE_CD IS 'Unique code to identify the official language (1=English, 2=French), Foreign key to TH019_LANGUAGE. Used to create the PERSONS record for new employees.';

CREATE INDEX AH029_IF7 ON AH029_HRSR_STAFFING
(STF_PREFERRED_LANGUAGE_CD   ASC);

ALTER TABLE AH029_HRSR_STAFFING
ADD CONSTRAINT AH029_TH019_FK FOREIGN KEY (STF_PREFERRED_LANGUAGE_CD) REFERENCES TH019_LANGUAGE (LNG_LANGUAGE_CD);


ALTER TABLE AH029_HRSR_STAFFING
ADD CONSTRAINT ALL_CONDITIONS_MET_IND CHECK (STF_ALL_CONDITIONS_MET_IND BETWEEN 0 AND 1);


ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_LETTER_OF_OFFER_RDIMS_NBR NUMBER(22));

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_LETTER_OF_OFFER_RDIMS_NBR IS 'The RDIMS number of the signed letter of offer.';



ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_UNDERFILL_GROUP_IND VARCHAR2(2));

ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_UNDERFILL_SUBGROUP_IND VARCHAR2(3));

ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_UNDERFILL_LEVEL_IND VARCHAR2(2));

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_UNDERFILL_GROUP_IND IS 'Identifies that the staffing action will be paid at an underfill classification. This colum represents the classification group the candidate will be paid at, if different from the assignment classification. Used mainly for Acting assignments. LEGACY COLUMN.

STF_UNDERFILL_GROUP_IND + STF_UNDERFILL_SUBGROUP_IND + STF_UNDERFILL_LEVEL_IND = STF Underfill Classification.

EX: Employee is an EX-01 classification, Acting as an EX-02, but it has been decided they will be paid at the underfill classification of AS-07. ';

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_UNDERFILL_SUBGROUP_IND IS 'Identifies that the staffing action will be paid at an underfill classification. This colum represents the classification subgroup the candidate will be paid at, if different from the assignment classification. Used mainly for Acting assignments. LEGACY COLUMN.

STF_UNDERFILL_GROUP_IND + STF_UNDERFILL_SUBGROUP_IND + STF_UNDERFILL_LEVEL_IND = STF Underfill Classification.

EX: Employee is an EX-01 classification, Acting as an EX-02, but it has been decided they will be paid at the underfill classification of AS-07. ';

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_UNDERFILL_LEVEL_IND IS 'Identifies that the staffing action will be paid at an underfill classification. This colum represents the classification level the candidate will be paid at, if different from the assignment classification. Used mainly for Acting assignments. LEGACY COLUMN.

STF_UNDERFILL_GROUP_IND + STF_UNDERFILL_SUBGROUP_IND + STF_UNDERFILL_LEVEL_IND = STF Underfill Classification.

EX: Employee is an EX-01 classification, Acting as an EX-02, but it has been decided they will be paid at the underfill classification of AS-07. ';



ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_DISCLAIMER_CONFIRM_IND NUMBER(1) CONSTRAINT DISCLAIMER_CONFIRM_IND CHECK (STF_DISCLAIMER_CONFIRM_IND BETWEEN 0 AND 1));

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_DISCLAIMER_CONFIRM_IND IS 'Indicates when the disclaimer has been confirmed by the Approver. Valid values are 1 = Yes, confirmed, 0 = No, NULL = Unknown at this time.';



ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_END_AT_LEVEL_ACTING_IND NUMBER(1) CONSTRAINT END_AT_LEVEL_ACTING CHECK (STF_END_AT_LEVEL_ACTING_IND BETWEEN 0 AND 1));

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_END_AT_LEVEL_ACTING_IND IS 'Indicator to identify the at level acting assignments for the candidate are to be ended when the HRSR is complete.  Valid values are 1 (end asn), 0 (do not end) or NULL (N/A or unknown at this time).';


ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_OATH_DTE DATE);

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_OATH_DTE IS 'Date the candidate has taken the oath.';



ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_LANGUAGE_REQ_MET_IND NUMBER(1) CONSTRAINT LANGUAGE_REQ_MET_IND CHECK (STF_LANGUAGE_REQ_MET_IND BETWEEN 0 AND 1));

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_LANGUAGE_REQ_MET_IND IS 'Indicator to determine if the candidate meets the language requirement of the position. 1 = Yes, 0 = No, NULL = Unknown at this time or not applicable.';
    
    
ALTER TABLE AH029_HRSR_STAFFING
    ADD (STF_DATE_LOO_SIGNED_DTE DATE);    

COMMENT ON COLUMN AH029_HRSR_STAFFING.STF_DATE_LOO_SIGNED_DTE IS 'Date the letter of offer (LOO) was signed by the candidate.';

