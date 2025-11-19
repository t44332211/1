CREATE OR REPLACE PROCEDURE AUTH_DB2_LUW_REPORT.USP_SERVERLIST_PARA ( )
  SPECIFIC USP_SERVERLIST_PARA
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL
  NOT DETERMINISTIC
  EXTERNAL ACTION
  MODIFIES SQL DATA
  CALLED ON NULL INPUT
  INHERIT SPECIAL REGISTERS
  OLD SAVEPOINT LEVEL
BEGIN 
 	DECLARE cur CURSOR WITH RETURN FOR
 		SELECT DISTINCT dbas.INSTANCE_CMDB_NAME
		FROM  AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_DATABASE dbas;
		
	OPEN cur;		
                                    
               
                                                                         
         
                                                                         
END