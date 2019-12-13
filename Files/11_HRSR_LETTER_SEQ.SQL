
CREATE SEQUENCE ah098_hrsr_letter_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

-- Grants for Sequence
GRANT SELECT ON ah098_hrsr_letter_seq TO tipsuser
/
GRANT SELECT ON ah098_hrsr_letter_seq TO everything_in_tips
/


CREATE SEQUENCE ah099_hrsr_letter_body_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

-- Grants for Sequence
GRANT SELECT ON ah099_hrsr_letter_body_seq TO tipsuser
/
GRANT SELECT ON ah099_hrsr_letter_body_seq TO everything_in_tips
/


CREATE SEQUENCE th188_hrsr_letter_section_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

-- Grants for Sequence
GRANT SELECT ON th188_hrsr_letter_section_seq TO tipsuser
/
GRANT SELECT ON th188_hrsr_letter_section_seq TO everything_in_tips
/




