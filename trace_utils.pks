CREATE OR REPLACE PACKAGE &&owner..trace_utils IS
   FUNCTION get_tracefile_name RETURN VARCHAR2;
   FUNCTION get_tracefile (p_file_name IN VARCHAR2) RETURN trace_coll PIPELINED;
   FUNCTION get_tkprof (p_file_name IN VARCHAR2) RETURN trace_coll PIPELINED;
   PROCEDURE start_sql_trace;
   PROCEDURE start_sql_trace(p_sqlid IN VARCHAR2);
   PROCEDURE stop_sql_trace;
   PROCEDURE start_optimiser_trace;
   PROCEDURE stop_optimiser_trace;
   PROCEDURE start_optimiser_trace (p_sqlid IN VARCHAR2);
END trace_utils;
/
SHO ERR
