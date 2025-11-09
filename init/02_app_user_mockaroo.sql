SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

-- Land in FREEPDB1 and APP
DECLARE
  v_con VARCHAR2(128) := SYS_CONTEXT('USERENV','CON_NAME');
BEGIN
  IF v_con = 'CDB$ROOT' THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = FREEPDB1';
  END IF;
END;
/
ALTER SESSION SET CURRENT_SCHEMA = APP;

SET SERVEROUTPUT ON
DECLARE
    v_start_time PLS_INTEGER;
    v_elapsed_time NUMBER;
    v_rows_inserted NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting 10 Bulk Insert Executions (1M rows each) ---');
    
    FOR i IN 1..10 LOOP 
        -- Capture start time in 1/100ths of a second
        v_start_time := DBMS_UTILITY.GET_TIME();
        
        -- Execute the INSERT statement
        INSERT /*+ APPEND */ INTO APP_USER_TABLE1 (OID, NAME, ZIPCODE, STATE, CITY)
        SELECT
            SYS_GUID(), -- OID
            SUBSTR(DBMS_RANDOM.STRING('U', 12), 1, 8 + MOD(ORA_HASH(LEVEL), 5)), -- NAME
            TRUNC(DBMS_RANDOM.VALUE(10001, 100000)), -- ZIPCODE
            CASE MOD(ORA_HASH(LEVEL), 50) -- STATE
                WHEN  0 THEN 'AL' WHEN  1 THEN 'AK' WHEN  2 THEN 'AZ' WHEN  3 THEN 'AR' WHEN  4 THEN 'CA'
                WHEN  5 THEN 'CO' WHEN  6 THEN 'CT' WHEN  7 THEN 'DE' WHEN  8 THEN 'FL' WHEN  9 THEN 'GA'
                WHEN 10 THEN 'HI' WHEN 11 THEN 'ID' WHEN 12 THEN 'IL' WHEN 13 THEN 'IN' WHEN 14 THEN 'IA'
                WHEN 15 THEN 'KS' WHEN 16 THEN 'KY' WHEN 17 THEN 'LA' WHEN 18 THEN 'ME' WHEN 19 THEN 'MD'
                WHEN 20 THEN 'MA' WHEN 21 THEN 'MI' WHEN 22 THEN 'MN' WHEN 23 THEN 'MS' WHEN 24 THEN 'MO'
                WHEN 25 THEN 'MT' WHEN 26 THEN 'NE' WHEN 27 THEN 'NV' WHEN 28 THEN 'NH' WHEN 29 THEN 'NJ'
                WHEN 30 THEN 'NM' WHEN 31 THEN 'NY' WHEN 32 THEN 'NC' WHEN 33 THEN 'ND' WHEN 34 THEN 'OH'
                WHEN 35 THEN 'OK' WHEN 36 THEN 'OR' WHEN 37 THEN 'PA' WHEN 38 THEN 'RI' WHEN 39 THEN 'SC'
                WHEN 40 THEN 'SD' WHEN 41 THEN 'TN' WHEN 42 THEN 'TX' WHEN 43 THEN 'UT' WHEN 44 THEN 'VT'
                WHEN 45 THEN 'VA' WHEN 46 THEN 'WA' WHEN 47 THEN 'WV' WHEN 48 THEN 'WI' WHEN 49 THEN 'WY'
            END,
            'City_' || SUBSTR(DBMS_RANDOM.STRING('A', 8), 1, 6) -- CITY
        FROM dual
        CONNECT BY LEVEL <= 1000000;
        
        -- Get the number of rows inserted (should be 1,000,000)
        v_rows_inserted := SQL%ROWCOUNT;
        
        -- Finalize the transaction and bulk index updates
        COMMIT; 
        
        -- Calculate elapsed time and convert from 1/100ths of a second to seconds
        v_elapsed_time := (DBMS_UTILITY.GET_TIME() - v_start_time) / 100;

        DBMS_OUTPUT.PUT_LINE('Run ' || LPAD(i, 2, '0') || ': Inserted ' || TO_CHAR(v_rows_inserted, '9,999,999') || 
                             ' rows in ' || TO_CHAR(v_elapsed_time, 'FM999.000') || ' seconds');
                             
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('--- 10 Bulk Insert Executions Complete ---');
END;
/


CREATE INDEX idx_user_state_zip 
ON APP_USER_TABLE2 (STATE, ZIPCODE);

SET SERVEROUTPUT ON
DECLARE
    v_start_time PLS_INTEGER;
    v_elapsed_time NUMBER;
    v_rows_copied NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting Bulk Data Copy (10M rows) ---');
    
    -- 1. Capture start time in 1/100ths of a second
    v_start_time := DBMS_UTILITY.GET_TIME();
    
    -- 2. Execute the Direct-Path INSERT statement
    INSERT /*+ APPEND */ INTO APP_USER_TABLE2 (OID, NAME, ZIPCODE, STATE, CITY)
    SELECT OID, NAME, ZIPCODE, STATE, CITY FROM APP_USER_TABLE1;
    
    -- Get the number of rows inserted
    v_rows_copied := SQL%ROWCOUNT;
    
    -- 3. Commit the transaction (includes deferred index maintenance)
    COMMIT; 
    
    -- 4. Calculate elapsed time and convert from 1/100ths of a second to seconds
    v_elapsed_time := (DBMS_UTILITY.GET_TIME() - v_start_time) / 100;

    DBMS_OUTPUT.PUT_LINE('Execution Complete:');
    DBMS_OUTPUT.PUT_LINE('Rows Copied: ' || TO_CHAR(v_rows_copied, '99,999,999'));
    DBMS_OUTPUT.PUT_LINE('Total Time:  ' || TO_CHAR(v_elapsed_time, 'FM999.000') || ' seconds');
    
END;
/

COMMIT;
-- done
