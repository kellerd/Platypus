Step #1:

Run script 00_START_HRSR_2_0.SQL in SQL Plus (or similiar software). This script will call all other scripts.

Step #2:

After scripts have been completed, if there are any remaining Invalid objects, please revalidate them using the stored procedure GLOBAL_REVALIDATE_OBJECTS, or manually.

Step #3: (CSA ONLY):

Run the file MANUAL_INSERT_HRSR2_PORTAL_MENU.SQL

