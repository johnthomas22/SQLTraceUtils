CREATE OR REPLACE PACKAGE BODY &&owner..trace_utils AS

    v_serialno v$session.serial#%TYPE;
    v_sql_id V$SQL.SQL_ID%TYPE;

    PROCEDURE start_sql_trace IS
    BEGIN 
       SYS.DBMS_SUPPORT.START_TRACE(waits=>TRUE, binds=>TRUE);
       DBMS_OUTPUT.PUT_LINE
       (
          'SQL trace started, please execute your SQL. Tracefile_name: ' || 
          &&owner..trace_utils.get_tracefile_name 
       );
    END start_sql_trace;
--
    PROCEDURE stop_sql_trace IS
    BEGIN 
       
       IF v_sql_id IS NULL THEN 

          SYS.DBMS_SUPPORT.STOP_TRACE;
          DBMS_OUTPUT.PUT_LINE
          (
             'Optimizer trace stopped. Tracefile_name in this session would be: ' || 
             &&owner..trace_utils.get_tracefile_name 
          );
       ELSE 

          EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''sql_trace [SQL: ' || v_sql_id || ' ] off''';
          DBMS_OUTPUT.PUT_LINE
          (
             'Optimizer trace stopped. See your SQL Tracefile_name: ' || 
             &&owner..trace_utils.get_tracefile_name 
          );
          v_sql_id := NULL;
       END IF;

    END stop_sql_trace;
-- 
    PROCEDURE start_sql_trace (p_sqlid IN VARCHAR2) IS
    BEGIN 
       v_sql_id := p_sqlid;
       EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''sql_trace [sql:' || p_sqlid || '] bind=true, wait=true''';
       DBMS_OUTPUT.PUT_LINE
       (
          'SQL trace set for SQL ID ' || p_sqlid || ', please execute your SQL. Tracefile_name in this session: ' || 
          &&owner..trace_utils.get_tracefile_name 
       );
       DBMS_OUTPUT.PUT_LINE
       (
          'You can fetch the tracefile name in another session using: SELECT &&owner..trace_utils.get_tracefile_name FROM dual;'
       );

    END start_sql_trace;
--
    PROCEDURE start_optimiser_trace IS

    BEGIN 

       SYS.DBMS_SYSTEM.SET_EV(si=> SYS.dbms_support.mysid, se=>v_serialno, ev=>10053, le=>1, nm=>'');
       DBMS_OUTPUT.PUT_LINE
       (
          'Optimizer trace started, please execute your SQL. Tracefile_name: ' || 
          &&owner..trace_utils.get_tracefile_name 
       );
    END start_optimiser_trace ;
--
    PROCEDURE stop_optimiser_trace IS
    BEGIN 

       IF v_sql_id IS NULL THEN 

          SYS.DBMS_SYSTEM.SET_EV(si=> SYS.dbms_support.mysid, se=>v_serialno, ev=>10053, le=>0, nm=>'');
          DBMS_OUTPUT.PUT_LINE
          (
             'Optimizer trace stopped. Tracefile_name: ' || 
             &&owner..trace_utils.get_tracefile_name 
          );
       ELSE 

          EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''trace[rdbms.SQL_Optimizer.*]off''';
          DBMS_OUTPUT.PUT_LINE
          (
             'Optimizer trace stopped. See your SQL Tracefile_name: ' || 
             &&owner..trace_utils.get_tracefile_name 
          );
          v_sql_id := NULL;
       END IF;

    END stop_optimiser_trace ;
--
    PROCEDURE start_optimiser_trace (p_sqlid IN VARCHAR2) IS
       
    BEGIN 
       v_sql_id := p_sqlid;

       EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''trace[rdbms.SQL_Optimizer.*][sql:' || p_sqlid || ']''';
       DBMS_OUTPUT.PUT_LINE
       (
          'Optimizer trace started, please execute your SQL. Tracefile_name in this session would be : ' || 
          &&owner..trace_utils.get_tracefile_name 
       );
       DBMS_OUTPUT.PUT_LINE
       (
          'You can fetch the tracefile name in another session using: SELECT &&owner..trace_utils.get_tracefile_name FROM dual;'
       );
    END start_optimiser_trace ;

--
    FUNCTION get_tracefile_name RETURN VARCHAR2 IS
        v_name   v$diag_info.value%TYPE;
    BEGIN
        SELECT
            regexp_substr(value,'[^/]+$') AS trace_file
        INTO
            v_name
        FROM
            v$diag_info
        WHERE
            name = 'Default Trace File';

--        dbms_output.put_line('Default trace file name: ' || v_name);

        RETURN v_name;

    END get_tracefile_name;
--
    FUNCTION get_tracefile ( p_file_name IN VARCHAR2 ) RETURN trace_coll
        PIPELINED
    IS
        PRAGMA autonomous_transaction;
        out_rec   trace_record := trace_record(NULL);
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TABLE &&owner..trace_file LOCATION (''' || p_file_name || ''')';
        FOR i IN (
            SELECT
                text
            FROM
                &&owner..trace_file
        ) LOOP
            out_rec.text := i.text;
            PIPE ROW ( out_rec );
        END LOOP;

        return;
    END get_tracefile;
--
    FUNCTION get_tkprof ( p_file_name IN VARCHAR2 ) RETURN trace_coll
        PIPELINED
    IS
        PRAGMA autonomous_transaction;
        out_rec   trace_record := trace_record(NULL);
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TABLE &&owner..tkprof LOCATION (''' || p_file_name || ''')';
        FOR i IN (
            SELECT
                text
            FROM
                &&owner..tkprof
        ) LOOP
            out_rec.text := i.text;
            PIPE ROW ( out_rec );
        END LOOP;

        return;
    END get_tkprof;

BEGIN 
       SELECT serial# 
       INTO v_serialno
       FROM v$session
       WHERE sid = SYS.dbms_support.mysid;
END trace_utils;
/

SHO ERR

