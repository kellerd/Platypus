

ALTER TABLE GROUPS
    ADD (GRP_GROUP_ENM VARCHAR2(75));

ALTER TABLE GROUPS
    ADD (GRP_GROUP_FNM VARCHAR2(75));

COMMENT ON COLUMN GROUPS.GRP_GROUP_ENM IS 'Full English name of the classificatation group. Used for HRSR 2.0';

COMMENT ON COLUMN GROUPS.GRP_GROUP_FNM IS 'Full French name of the classificatation group. Used for HRSR 2.0';


ALTER TABLE GROUPS
    ADD (GRP_HRSR_ACTIVE_IND NUMBER(1)  DEFAULT 1 CONSTRAINT GRP_HRSR_ACTIVE_IND CHECK (GRP_HRSR_ACTIVE_IND BETWEEN 0 AND 1));

COMMENT ON COLUMN GROUPS.GRP_HRSR_ACTIVE_IND IS 'Indicator identifying the group as active in picklists and creation of new assignments in HRSR. Valid values are 1 = Active, 0 = Inactive, NULL = Unknown at this time. ';

