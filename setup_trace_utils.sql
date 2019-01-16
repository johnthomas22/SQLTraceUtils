/*

Usage: 

SELECT &&owner..trace_utils.get_tracefile_name FROM dual;

SELECT * FROM TABLE(&&owner..trace_utils.get_tkprof(&&owner..trace_utils.get_tracefile_name));

   Some types on which to base a table function

*/

DECLARE
   not_exists EXCEPTION;
   PRAGMA exception_init(not_exists, -04043);
BEGIN 
   EXECUTE IMMEDIATE 'DROP TYPE &&owner..trace_coll';
EXCEPTION WHEN not_exists THEN DBMS_OUTPUT.PUT_LINE('Type trace_coll did not already exist');
END;
/

DECLARE
   not_exists EXCEPTION;
   PRAGMA exception_init(not_exists, -04043);
BEGIN 
   EXECUTE IMMEDIATE 'DROP TYPE &&owner..trace_record';
EXCEPTION WHEN not_exists THEN DBMS_OUTPUT.PUT_LINE('Type trace_record did not already exist');
END;
/

CREATE TYPE &&owner..trace_record AS OBJECT
(
   text VARCHAR2(4000)
);
/

CREATE TYPE &&owner..trace_coll AS TABLE OF trace_record;
/

DROP TABLE &&owner..tkprof
/

CREATE TABLE &&owner..tkprof
( line  NUMBER
  , text  VARCHAR2(4000)
)
ORGANIZATION EXTERNAL
(
TYPE ORACLE_LOADER
DEFAULT DIRECTORY user_dump_dest
ACCESS PARAMETERS
(
   RECORDS DELIMITED BY NEWLINE
   NOLOGFILE
   PREPROCESSOR bin_dir: 'tkprof.sh'
   FIELDS TERMINATED BY WHITESPACE
   (
      line RECNUM
   ,  text POSITION(1:4000)
   )
)
LOCATION ('')
)
REJECT LIMIT UNLIMITED;

CREATE TABLE &&owner..trace_file
(
  TEXT VARCHAR2(2000) 
) 
ORGANIZATION EXTERNAL 
( 
  TYPE ORACLE_LOADER 
  DEFAULT DIRECTORY user_dump_dest 
  LOCATION 
  ( 
    '' 
  ) 
)
REJECT LIMIT UNLIMITED
/

@@trace_utils.pks
@@trace_utils.pkb
