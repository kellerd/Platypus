-- This is the script to start the database changes for HRSR 2.0 Release
-- Transport Canada Copy

SET VERIFY OFF
SET HEAD OFF
SET DEFINE OFF
SET SQLBLANKLINES ON

SPOOL hrsr_release_2_0.txt
PROMPT HRSR 2.0 Release Database Scripts...

SELECT 'Start time: '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS am')
   FROM DUAL;
   
PROMPT
PROMPT *************************************************************
PROMPT HRSR 2.0 RELEASE 
PROMPT *************************************************************
PROMPT

PROMPT Database Scripts...

PROMPT CREATE TABLES...
@@ 01_AH096_HRSR_USER_SEARCH.SQL
@@ 03_TH189_EMPLOYMENT_TYPE.SQL
@@ 04_HRSR_PT_HOURS_TABLE.SQL
@@ 112_AH031_HRSR_CASUAL.SQL
@@ 05_TH191_HRSR_ERROR_MESSAGE.SQL
@@ 06_TH056_ALTER_TABLE.SQL
@@ 07_TH196_STUDENT_BUD_CODE.SQL
@@ 08_HRSR_CONDITIONS_OF_EMPLOY.SQL
@@ 09_HRSR_LETTER_TABLES.SQL
@@ 10_TH190_XREF_TH048_TH189.SQL
@@ 12_AH102_LETTER_OF_OFFER.SQL
@@ 13_AH029_HRSR_STAFFING.SQL
@@ 14_AH103_CUSTOM_CONDITION_OF_EMPL.SQL
@@ 15_TH197_TI_PROFILE.SQL
@@ 106_TH198_HRSR_WORK_HOURS.SQL
@@ 109_HRSR_FORM_TABLES.SQL
@@ 113_TH048_HRSR_ACTION.SQL
@@ 114_MILESTONE_PROGRESS_TRACKER.SQL
@@ 121_AH108_HRSR_RESTRICTED_ACCESS.SQL
@@ 126_AH109_HRSR_CANDIDATE_SIN.SQL
@@ 129_AH027_HRSR_REQUEST.SQL
@@ 133_AH032_HRSR_RDIMS_ATTACHMENT.SQL
@@ 155_TH050_HRSR_STATUS_ALTER.SQL
@@ 179_AH095_HRSR_STUDENT_DETAILS.SQL
@@ 180_TH204_XREF_STAFFING_VALIDATION.SQL
@@ 184_ALTER_GROUPS.SQL
@@ 187_TH205_XREF_TH048_ASN_TYPE.SQL
@@ 192_AH110_HRSR_LETTER_CONTACT.SQL

PROMPT CREATE SEQUENCES...
@@ 02_AH096_SEARCH_ID_SEQ.SQL
@@ 11_HRSR_LETTER_SEQ.SQL
@@ 182_TH204_STAFF_VALIDATE_SEQ.SQL

PROMPT CREATE FUNCTIONS...
@@ 32_FN_GET_USER.SQL
@@ 30_FN_GET_HRSR_ERROR_MESSAGE_TXT.SQL     ---- REMOVE? 
@@ 31_FN_GET_PREVIOUS_GEO_PROVINCE.SQL
@@ 104_FN_HRSR_LANGUAGE_PROFILE.SQL
@@ 131_FN_GET_PREVIOUS_ASN_TYPE.SQL
@@ 139_FN_ACCENT_INSENSITIVE.SQL
@@ 145_FN_GET_HRSR_ERROR_MESSAGE_ETXT.SQL
@@ 146_FN_GET_HRSR_ERROR_MESSAGE_FTXT.SQL
@@ 154_FN_HRSR_SELECTION_PROCESS_NMBR.SQL
@@ 162_FN_MEETS_SECURITY_REQ.SQL
@@ 164_FN_MEETS_LANGUAGE_PROFILE.SQL
@@ 168_FN_POSITION_CLASSN_FLAG.SQL
@@ 205_FN_ACTING_LAST_END_DTE.SQL

PROMPT CREATE FUNCTIONS AND PROCEDURES DEPENDENT ON VIEWS...
@@ 101_VW_HRSR_DEPLOYMENT_CALCULATOR.SQL
@@ 103_FN_DEPLOYMENT_CALCULATOR.SQL
@@ 144_FN_VALIDATE_ACTING_ASSIGNMENT.SQL    ----- REMOVE?

PROMPT CREATE TRIGGERS...
@@ 40_AUDIT_MASTER_UPDATE.SQL
@@ 19_AH103_TRIGGER.SQL
@@ 20_TH196_TRIGGER.SQL
@@ 21_TH197_TRIGGER.SQL
@@ 22_HRSR_CONDITIONS_OF_EMPLOY_TRIGGERS.SQL
@@ 23_TH190_TG1_BUID_AUDIT.SQL
@@ 24_TH189_TG1_BUID_AUDIT.SQL
@@ 25_HRSR_PT_HOURS_TRIGGER.SQL
@@ 26_HRSR_LETTER_TRIGGERS.SQL
@@ 27_AH096_TG1_BUID_AUDIT.SQL
@@ 28_TH191_TG1_BUID_AUDIT.SQL
@@ 29_AH102_TG1_BIUD_AUDIT.SQL
@@ 135_AH035_TG1_BIUD_AUDIT.SQL
@@ 107_TH198_TRIGGER.SQL
@@ 110_HRSR_FORM_TRIGGERS.SQL
@@ 115_MILESTONE_PROGRESS_TRIGGERS.SQL
@@ 117_AH029_TG1_BIUD_AUDIT.SQL
@@ 118_AH027_TG1_AIUD_LOG.SQL
@@ 122_AH108_TG1_BIUD_AUDIT.SQL
@@ 127_AH109_TG1_BIUD_AUDIT.SQL
@@ 135_AH035_TG1_BIUD_AUDIT.SQL
@@ 156_TH050_TG1_BIUD_AUDIT.SQL
@@ 171_AH027_TG1_BIUD_AUDIT.SQL
@@ 177_AH032_TG1_BIUD_AUDIT.SQL
@@ 178_AH095_TG1_BIUD_AUDIT.SQL
@@ 181_TH204_TRIGGER.SQL
@@ 188_TH205_TG1_BIUD_AUDIT.SQL
@@ 193_AH110_TG1_BIUD_AUDIT.SQL
@@ 198_AH033_TG1_BIUD_AUDIT.SQL
@@ 199_AH028_TG1_BIUD_AUDIT.SQL
@@ 200_AH030_TG1_BIUD_AUDIT.SQL
@@ 201_AH031_TG1_BIUD_AUDIT.SQL
@@ 202_AH034_TG1_BIUD_AUDIT.SQL
@@ 203_AH080_TG1_BIUD_AUDIT.SQL
@@ 204_CAST01.SQL


PROMPT CREATE VIEWS...
@@ 50_VW_HRSR_GEOGRAPHIC_LOCATIONS.SQL
@@ 51_VW_HRSR_APPROVER.SQL
@@ 52_VW_HRSR_APPROVER_SEARCH.SQL
@@ 91_VH007_EMPLOYMENT_TYPE.SQL
@@ 92_VH053_HRSR_PERSON_ACTIVE.SQL
@@ 93_VH054_HRSR_PERSON_INACTIVE.SQL
@@ 94_VH059_HRSR_PERSON_SECONDMENT.SQL
@@ 95_VW_HRSR_ACTION_PICKLIST.SQL
@@ 96_VW_HRSR_CAF_SELECTION_PROCESS.SQL
@@ 97_VW_HRSR_CASUAL_LETTER_OF_OFFER.SQL
@@ 98_VW_HRSR_LETTER_TEMPLATE.SQL
@@ 99_VW_HRSR_STUDENT_LETTER_DATA.SQL
@@ 100_VW_XREF_HRSR_CAF_REA.SQL
@@ 105_VW_HRSR_CASUAL_LETTER_DATA.SQL
@@ 119_VW_HRSR_TIMELINE_DATA.SQL
@@ 123_VW_HRSR_RESTRICTED_ACCESS.SQL
@@ 124_VW_HRSR_CASE_FILES.SQL
@@ 125_VW_HRSR_PRINT_STAFFING_REQUEST.SQL
@@ 128_VW_HRSR_ACTIVE_PAY_RATES.SQL
@@ 137_VW_HRSR_ACTIVE_CLASSIFICATION.SQL
@@ 138_VW_HRSR_POSITION_INFO_DETAILS.SQL
@@ 140_VW_HRSR_CANDIDATE_INFO_DETAILS.SQL
@@ 142_VW_HRSR_ACTIVE_SUBSTANTIVE_ASN.SQL
@@ 143_VW_HRSR_LINGUISTIC_REQ_DETAILS.SQL
@@ 150_VH055_HRSR_PERSON_RECOMMENDER.SQL
@@ 151_VH056_HRSR_PERSON_APPROVER.SQL
@@ 152_VH057_HRSR_PERSON_ADVISOR.SQL
@@ 153_VH058_HRSR_PERSON_INITIATOR.SQL
@@ 158_VW_HRSR_ACTIVE_FUTURE_ASN.SQL
@@ 159_VW_HRSR_OVERLAPPING_ASN.SQL
@@ 160_VW_HRSR_EMPLOYEE_INFO_DETAILS.SQL
@@ 169_VW_HRSR_LAST_MILESTONE.SQL
@@ 176_VW_HRSR_STUDENT_PAY_RATES.SQL
@@ 185_VW_HRSR_COLLECTIVE_AGREEMENTS.SQL

PROMPT FUNCTIONS AND PROCEDURES DEPENDENT ON VIEWS...
@@ 191_FN_GET_MAX_SALARY_FOR_CLASSN.SQL

PROMPT CREATE PROCEDURES...
@@ 41_ARCHIVE_VACANT_PHANT_POSITIONS.SQL
@@ 42_HRSR_CAF_UPDATE_CLOSE_REQUEST.SQL
@@ 136_SEND_EMAIL_HRSR_RETURN_TO_USER.SQL
@@ 165_SEND_EMAIL_HRSR_EXCLUSION_UNIT.SQL
@@ 195_SEND_EMAIL_HRSR_TAP_PHANT_POS.SQL
@@ 196_SEND_EMAIL_HRSR_EXCLUSION_UNIT.SQL
@@ 197_SEND_EMAIL_HRSR.SQL
@@ 147_SP_VALIDATE_ACTING_ASSIGNMENT.SQL
@@ 148_SP_VALIDATE_UNDERFILL_ASN.SQL
@@ 149_SP_VALIDATE_ACTING_PROMOTION.SQL
@@ 161_SEND_EMAIL_HRSR_REASSIGNED.SQL
@@ 163_SP_VALIDATE_ACTING_WARNINGS.SQL
@@ 165_SEND_EMAIL_HRSR_EXCLUSION_UNIT.SQL
@@ 172_SP_VALIDATE_STUDENT_ASSIGNMENT.SQL
@@ 173_SP_VALIDATE_CASUAL_ASSIGNMENT.SQL
@@ 174_SP_VALIDATE_STUDENT_WARNINGS.SQL
@@ 175_SP_VALIDATE_CASUAL_WARNINGS.SQL 
@@ 190_SP_VALIDATE_PT_HOURS_SCHEDULER.SQL

@@ 43_HRSR_CREATE_STAFFING_ACTION.SQL


PROMPT LOAD DATA...
@@ 64_HRSR_LETTER_DATA.SQL
@@ 60_AH099_DATA_INSERT_STUDENT.SQL
@@ 61_AH099_DATA_INSERT_STUDENT_ABO.SQL
@@ 62_AH099_DATA_INSERT_STUDENT_AS_WHEN.SQL
@@ 63_HRSR_CONDITIONS_OF_EMPLOY_DATA.SQL
@@ 65_HRSR_PT_HOURS_DATA.SQL
@@ 67_TH056_UPDATE_DATA.SQL
@@ 68_TH189_INSERT_DATA.SQL
@@ 66_TH048_NEW_ACTION_CODES.SQL
@@ 69_TH190_LOAD_DATA.SQL
@@ 70_TH191_HRSR_ERROR_MESSAGE_DATA.SQL
@@ 71_TH196_LOAD_DATA.SQL
@@ 72_TH197_TI_PROFILE_DATA.SQL
@@ 73_AH099_DATA_INSERT_CASUAL.SQL
@@ 108_TH198_DATA.SQL
@@ 116_TH202_MILESTONE_DATA.SQL
@@ 132_HRSR_EMAIL_TXT.SQL
@@ 134_TH051_DATA_INSERT.SQL
@@ 157_TH050_CONFIRM_DIALOGUE.SQL
@@ 166_HRSR_EMAILS.SQL
@@ 167_TH048_DISCLAIMER_DATA.SQL
@@ 170_CREATE_HR_TRIAGE_USERS.SQL
@@ 183_TH204_LOAD_DATA.SQL
@@ 186_UPDATE_GROUPS_DATA.SQL
@@ 189_TH205_LOAD_DATA.SQL
@@ 194_TH200_DATA_INSERT.SQL
@@ 206_CLASSN_FLAG_DATA.SQL

PROMPT MATERIALIZED VIEW...
@@ 90_MV001_HRSR_PERSON_SEARCH.SQL
@@ 130_MV001_IE1_INDEX.SQL 
@@ 141_MV_INDEXES.SQL
@@ 120_VW_HRSR_MILESTONE_PROGRESS.SQL

PROMPT CREATE FUNCTIONS AND PROCEDURES DEPENDENT ON VIEWS...
@@ 81_SP_HRSR_GENERATE_LETTER.SQL


PROMPT REVALIDATE OBJECTS...
@@ 999_REVALIDATE_OBJECTS.SQL

PROMPT TIPS VERSION...
@@ 999_TIPS_VERSION.SQL

PROMPT
PROMPT
PROMPT *************************************************************
PROMPT ***** THE FOLLOWING OBJECTS STILL NEED TO BE RECOMPILED *****

SELECT 'ALTER '||object_type||' '||object_name||' COMPILE;'
  FROM dba_objects
 WHERE status = 'INVALID'
   AND owner = 'TIPS'
 ORDER BY object_type, object_name;

PROMPT *************************************************************

SELECT 'End Time: '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS am')
   FROM DUAL;

SPOOL OFF



