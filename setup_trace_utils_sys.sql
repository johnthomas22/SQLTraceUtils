/*
   We need a database directory a function can access for user_dump_dest. 

As SYS:
*/
SET ECHO ON 

DEF owner = "sqlutils"

SET ECHO OFF 
ACCEPT owner PROMPT "Enter name of schema to own utilities (Default: sqlutils): " DEFAULT "sqlutils"
ACCEPT dropowner PROMPT "Drop user &&owner and recreate (Y/N, Default:N): " DEFAULT "N"
SET ECHO ON 

BEGIN
   IF UPPER('&&dropowner') IN ('YES', 'Y') THEN 
      EXECUTE IMMEDIATE 'DROP USER &&owner CASCADE';
   END IF;
END;
/

COL user_dump_dest NEW_VALUE user_dump_dest 

SELECT v1.value || '/diag/rdbms/' || LOWER(v2.value) || '/' || i.instance_name || '/trace' user_dump_dest 
FROM v$parameter  v1, v$parameter v2, v$instance i
WHERE v1.name = 'diagnostic_dest'
AND v2.name = 'db_unique_name';

CREATE OR REPLACE DIRECTORY user_dump_dest AS '&&user_dump_dest';

/*
   Needs write access to be able to write the log file
*/

ACCEPT passwd HIDE PROMPT "Enter password for &&owner: "


CREATE USER &&owner IDENTIFIED BY &&passwd;

GRANT CREATE PROCEDURE TO &&owner;

GRANT READ, WRITE ON DIRECTORY user_dump_dest TO &&owner;

CREATE OR REPLACE DIRECTORY bin_dir AS '/home/oracle/scripts';

GRANT READ, EXECUTE ON DIRECTORY bin_dir TO &&owner;

GRANT EXECUTE ON SYS.DBMS_SUPPORT TO &&owner;

GRANT EXECUTE ON SYS.DBMS_SYSTEM TO &&owner;

GRANT SELECT ON v_$session TO &&owner;

GRANT SELECT ON v_$sql TO &&owner;

HOST mkdir ~/scripts

HOST cp ./tkprof.sh ~/scripts

HOST chmod u+x ~/scripts/tkprof.sh

@?/rdbms/admin/dbmssupp
@@setup_trace_utils.sql
