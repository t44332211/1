CREATE OR REPLACE PROCEDURE AUTH_DB2_LUW_REPORT.USP_PERSONROLELIST_PARA ( )
  SPECIFIC USP_PERSONROLELIST_PARA
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL
  NOT DETERMINISTIC
  EXTERNAL ACTION
  MODIFIES SQL DATA
  CALLED ON NULL INPUT
  INHERIT SPECIAL REGISTERS
  OLD SAVEPOINT LEVEL
BEGIN 
  -- Required: procedure body with statements.  Each statement must be terminated with a semicolon.
  -- e.g. DECLARE cursor1 CURSOR WITH RETURN FOR SELECT PROCSCHEMA, PROCNAME FROM SYSCAT.PROCEDURES; 
  DECLARE cur CURSOR WITH RETURN FOR
		select RPAD('DataEnabler',35) 	PersonRole from sysibm.sysdummy1   
		union all
        select RPAD('DataOwner',35) 	PersonRole from sysibm.sysdummy1   
        union all
        select RPAD('DataSteward',35) 	PersonRole from sysibm.sysdummy1;
        
    OPEN cur;
  -- Optional: exception expressions
  -- EXCEPTION 
  -- WHEN { exception-condition } THEN { statement; } ... { statement; } 
  -- ... 
  -- WHEN { exception-condition } THEN { statement; } ... { statement; } 
END