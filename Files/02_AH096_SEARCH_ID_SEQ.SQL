
CREATE SEQUENCE ah096_search_id_seq
  INCREMENT BY 1
  START WITH 11
  MINVALUE 11
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

-- Grants for Sequence
GRANT SELECT ON ah096_search_id_seq TO tipsuser
/
GRANT SELECT ON ah096_search_id_seq TO everything_in_tips
/



