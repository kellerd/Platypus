-- Start of DDL Script for Procedure TIPS.ARCHIVE_VACANT_PHANT_POSITIONS
-- Generated 2019-05-16 4:24:11 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE archive_vacant_phant_positions
 IS
-- Created by: Jennifer Hynes, April 9, 2001
--
-- Purpose: Archive Phantom Positions which are vacant more than a month and do
--          not have any non-vacant subordinate positions assigned to them.
--
--          This procedure is scheduled to be run once a week in Sunday.
--          This procedure was initially designed as per the requirements of
--          PR#235561, but was not moved to production until change request
--          CRBD-00747.
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- --------   ---------  -------------------------------------------------------
-- Hynes, J.  16-MAY-19  HRSR 2.0. Check for TA open case files as well as STF.
--
-- Hu,    H.  01-FEB-13  TIPS_GLOB-01752: Revert the archiving of phantom
--                       position numbers from three months to one month.
--                       And do not archive those positions with staffing case
--                       file assigned to and is still open
--
-- Hynes, J.  25-MAY-12  IM77599: Modified to check ALL_ASSIGNMENTS to see if
--                       position has ever had an assignment.
--
-- Hynes, J.  02-AUG-11  TIPS_GLOB-01635: Modified to archieve positions 3 mths
--                       after assignment end date.
--
-- Hynes, J.  13-MAR-09  PR#292194: When position is moved to OLD_POSITIONS,
--                       any active records in AH012_POSITION_PROFILE_DETAIL
--                       will have the POP_DATE_DELETE_DTE set to SYSDATE
--
-- Hynes, J.  14-JUN-06  ORG_PRO-01108: Added a call to the procedure
--                       SEND_EMAIL_VACANT_PHANTOM_POS.
--
-- Hynes, J.  20-JAN-04  STAFFING-00862: Archive only positions that have
--                       actually had an assignment at some point.  This will
--                       prevent student positions from being archived when they
--                       create the position ahead of time before they have
--                       someone to staff the position.
--

   v_return_message_nmbr NUMBER;

BEGIN
   FOR old_phantom_pos IN (
    SELECT pos_position_nmbr
                FROM tips.positions a
               WHERE a.pos_vacant_flag = '1'  -- position is vacant
                 AND a.pos_position_nmbr LIKE '%ZZZ%'
                 AND NOT EXISTS (SELECT pos_position_nmbr -- subordinate positions
                                   FROM tips.positions b
                                  WHERE b.pos_parent_position_nmbr =
                                        a.pos_position_nmbr
                                    AND b.pos_vacant_flag = '0') -- not vacant
                 -- Archive only those positions that have not had someone in the
                 -- the position for over 3 months:
                 --TIPS_GLOB-01752
                 AND NOT EXISTS (SELECT *
                                   FROM tips.assignments
                                  WHERE asn_position_nmbr = a.pos_position_nmbr
                                    AND NVL(asn_effective_end_date, SYSDATE) >=
                                        ADD_MONTHS(SYSDATE,-1))
                 -- Archive only positions that have actually had an assignment at
                 -- some point.  This will prevent student positions from being
                 -- archived when they create the position ahead of time before they
                 -- have someone to staff the position.
                 AND EXISTS (SELECT *
                               FROM all_assignments
                              WHERE asn_position_nmbr = a.pos_position_nmbr)
                 --TIPS_GLOB-01752
                 AND NOT EXISTS(SELECT *
                                  FROM case_files
                                 WHERE caf_category_ind IN ('STF','TA')
                                   AND caf_object_code =a.pos_position_nmbr
                                   AND caf_case_status_ind  in ('1','4'))
             ) LOOP

              -- Phantom position records are archived now that they are no
              -- longer needed (those considered vacant):
              INSERT INTO old_positions
                   SELECT *
                     FROM positions
                    WHERE pos_position_nmbr = old_phantom_pos.pos_position_nmbr;

              UPDATE ah012_position_profile_detail
                 SET pop_date_delete_dte = SYSDATE
               WHERE pop_position_nmbr = old_phantom_pos.pos_position_nmbr
                 AND pop_date_delete_dte IS NULL;

              -- Then delete the old position record:
              DELETE
                FROM positions a
               WHERE a.pos_position_nmbr = old_phantom_pos.pos_position_nmbr
                 AND EXISTS (SELECT *
                               FROM old_positions b
                              WHERE b.pos_position_nmbr = a.pos_position_nmbr);
   END LOOP;
  COMMIT;
  -- Send email if there are phantom positions that will expire in the next
  -- 7 days that have other positions reporting to them:
  SEND_EMAIL_VACANT_PHANTOM_POS(v_return_message_nmbr);
END;
/


-- End of DDL Script for Procedure TIPS.ARCHIVE_VACANT_PHANT_POSITIONS

