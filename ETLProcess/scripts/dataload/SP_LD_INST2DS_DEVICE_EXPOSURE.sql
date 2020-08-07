/************************************************************
project : N3C DI&H
Date: 5/16/2020
Authors: 
Stephanie Hong, Sandeep Naredla, Richard Zhu, Tanner Zhang
Stored Procedure : SP_LD_INST2DS_DEVICE_EXPOSURE

Description : Load data from instance to DS

*************************************************************/

CREATE PROCEDURE CDMH_STAGING.SP_LD_INST2DS_DEVICE_EXPOSURE 
(
  DATAPARTNERID IN NUMBER 
, MANIFESTID IN NUMBER 
, RECORDCOUNT OUT NUMBER
) 
AS
/********************************************************************************************************
     Name:      SP_LD_INST2DS_CONDITION_OCCUR
     Purpose:    Loading The N3C_Instance.CONDITION_OCCURRENCE Table into N3C_DS.CONDITION_OCCURRENCE
     Source:
     Revisions:
     Ver          Date        Author               Description
     0.1        6/29/2020     SNAREDLA             Initial Version
*********************************************************************************************************/
/******************************************************
*  CONSTANTs
******************************************************/
COMMIT_LIMIT CONSTANT NUMBER := 10000;
loop_count NUMBER;
insert_rec_count NUMBER;
/**************************************************************
*  Cursor for selecting table
**************************************************************/
CURSOR Device_Cursor IS
SELECT DEVICE_EXPOSURE_ID,
PERSON_ID,
DEVICE_CONCEPT_ID,
DEVICE_EXPOSURE_START_DATE,
DEVICE_EXPOSURE_START_DATETIME,
DEVICE_EXPOSURE_END_DATE,
DEVICE_EXPOSURE_END_DATETIME,
DEVICE_TYPE_CONCEPT_ID,
UNIQUE_DEVICE_ID,
QUANTITY,
PROVIDER_ID,
VISIT_OCCURRENCE_ID,
VISIT_DETAIL_ID,
DEVICE_SOURCE_VALUE,
DEVICE_SOURCE_CONCEPT_ID,
  DATAPARTNERID AS DATA_PARTNER_ID
FROM N3C_OMOP531_Instance.DEVICE_EXPOSURE ;
TYPE l_val_cur IS TABLE OF Device_Cursor%ROWTYPE;
values_rec l_val_cur;

BEGIN
/******************************************************
* DELETE PREVIOUS RUN DATA
******************************************************/
DELETE FROM N3C_OMOP531_DS.DEVICE_EXPOSURE WHERE DATA_PARTNER_ID=DATAPARTNERID;
COMMIT;
/**************************************************************
_  VARIABLES:
*  loop_count - counts loop iterations for COMMIT_LIMIT
**************************************************************/
   loop_count := 0;
   insert_rec_count := 0;
/******************************************************
* Beginning of loop on each record in cursor.
******************************************************/
open Device_Cursor;
  LOOP
    FETCH Device_Cursor bulk collect into values_rec limit 10000;
    EXIT WHEN values_rec.COUNT=0;
BEGIN
   FORALL i IN 1..values_rec.COUNT
	   INSERT INTO N3C_OMOP531_DS.DEVICE_EXPOSURE VALUES values_rec(i);
        COMMIT;
	END;
         insert_rec_count := insert_rec_count+ values_rec.COUNT;
--         dbms_output.put_line('Number of records inserted during loop = '||insert_rec_count);
END LOOP;
RECORDCOUNT :=insert_rec_count;
COMMIT;
Close Device_Cursor;
dbms_output.put_line('Number of records inserted are = '||RECORDCOUNT);
END SP_LD_INST2DS_DEVICE_EXPOSURE;
