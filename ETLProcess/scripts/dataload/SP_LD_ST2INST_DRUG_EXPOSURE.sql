/************************************************************
project : N3C DI&H
Date: 5/16/2020
Authors: 
Stephanie Hong, Sandeep Naredla, Richard Zhu, Tanner Zhang
Stored Procedure : SP_LD_ST2INST_DRUG_EXPOSURE

Description : Load data from staging to instance

*************************************************************/
CREATE PROCEDURE CDMH_STAGING.SP_LD_ST2INST_DRUG_EXPOSURE (
  DATAPARTNERID IN NUMBER 
, MANIFESTID IN NUMBER 
, RECORDCOUNT OUT NUMBER
) 
AS
/********************************************************************************************************
     Name:      SP_LD_ST2INST_DRUG_EXPOSURE
     Purpose:    Loading The CDMH_STAGING.DRUG_EXPOSURE Table into N3C_Instance.DRUG_EXPOSURE
     Source:
     Revisions:
     Ver          Date        Author               Description
     0.1        6/29/2020     TZHANG             Initial Version
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
CURSOR DRUG_EXPOSURE_Cursor IS
SELECT DRUG_EXPOSURE_ID,
PERSON_ID,
DRUG_CONCEPT_ID,
DRUG_EXPOSURE_START_DATE,
DRUG_EXPOSURE_START_DATETIME,
DRUG_EXPOSURE_END_DATE,
DRUG_EXPOSURE_END_DATETIME,
VERBATIM_END_DATE,
DRUG_TYPE_CONCEPT_ID,
STOP_REASON,
REFILLS,
QUANTITY,
DAYS_SUPPLY,
SIG,
ROUTE_CONCEPT_ID,
LOT_NUMBER,
PROVIDER_ID,
VISIT_OCCURRENCE_ID,
VISIT_DETAIL_ID,
DRUG_SOURCE_VALUE,
DRUG_SOURCE_CONCEPT_ID,
ROUTE_SOURCE_VALUE,
DOSE_UNIT_SOURCE_VALUE
FROM CDMH_STAGING.ST_OMOP53_DRUG_EXPOSURE 
WHERE DATA_PARTNER_ID=DATAPARTNERID AND MANIFEST_ID=MANIFESTID;
TYPE l_val_cur IS TABLE OF DRUG_EXPOSURE_Cursor%ROWTYPE;
values_rec l_val_cur;

BEGIN

/**************************************************************
_  VARIABLES:
*  loop_count - counts loop iterations for COMMIT_LIMIT
**************************************************************/
   loop_count := 0;
   insert_rec_count := 0;
/******************************************************
* Beginning of loop on each record in cursor.
******************************************************/
open DRUG_EXPOSURE_Cursor;
  LOOP
    FETCH DRUG_EXPOSURE_Cursor bulk collect into values_rec limit 10000;
    EXIT WHEN values_rec.COUNT=0;
BEGIN
   FORALL i IN 1..values_rec.COUNT
	   INSERT INTO N3C_OMOP531_INSTANCE.DRUG_EXPOSURE VALUES values_rec(i);
        COMMIT;
	END;
         insert_rec_count := insert_rec_count+ values_rec.COUNT;
--         dbms_output.put_line('Number of records inserted during loop = '||insert_rec_count);
END LOOP;
RECORDCOUNT :=insert_rec_count;
COMMIT;
Close DRUG_EXPOSURE_Cursor;
dbms_output.put_line('Number of records inserted are = '||RECORDCOUNT);

END SP_LD_ST2INST_DRUG_EXPOSURE;
