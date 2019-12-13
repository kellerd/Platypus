COMMENT ON COLUMN AH031_HRSR_CASUAL.CSL_CASUAL_REASON_IND IS 'Foreign key to TH194_CASUAL_REASON identifying the casual reason code. Based on the values in GLOBAL_VALIDATIONS where glv_val_name = CASUAL_REASON_TYPE. LEGACY COLUMN NAMING CONVENTION.';

CREATE INDEX AH031_IF3 ON AH031_HRSR_CASUAL
(CSL_CASUAL_REASON_IND   ASC);

INSERT INTO th194_casual_reason (casual_reason_cd, casual_reason_enm, casual_reason_fnm)
SELECT glv_val_value_ind, glv_val_desc_e, glv_val_desc_f
  FROM global_validations 
 WHERE glv_val_name = 'CASUAL_REASON_TYPE'
 ORDER BY glv_val_value_ind; 

COMMIT;

ALTER TABLE AH031_HRSR_CASUAL
ADD CONSTRAINT AH031_TH194_FK FOREIGN KEY (CSL_CASUAL_REASON_IND) REFERENCES TH194_CASUAL_REASON (CASUAL_REASON_CD);

