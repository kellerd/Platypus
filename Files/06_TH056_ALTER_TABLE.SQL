
ALTER TABLE TH056_XREF_TH048_FUA
    ADD (EXT_EXTENSION_CD VARCHAR2(1));

COMMENT ON COLUMN TH056_XREF_TH048_FUA.EXT_EXTENSION_CD IS 'Foreign key to TH053_EXTENSION_CD.  The HRSR extension associated with the record ';

CREATE INDEX TH056_IF3 ON TH056_XREF_TH048_FUA
(EXT_EXTENSION_CD   ASC);

ALTER TABLE TH056_XREF_TH048_FUA
ADD CONSTRAINT TH056_TH053_FK FOREIGN KEY (EXT_EXTENSION_CD) REFERENCES TH053_EXTENSION_CD (EXT_EXTENSION_CD);

