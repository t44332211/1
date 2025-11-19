CREATE OR REPLACE PROCEDURE AUTH_DB2_LUW_REPORT.USP_GLOBALPERM_DATA (
    IN P_DB_CMDB_NAME	VARCHAR(100),
    IN P_TIMESTAMP	VARCHAR(40),
    IN P_PREVTIMESTAMP	VARCHAR(40),
    IN P_PERSONROLE	VARCHAR(40),
    IN P_WHITELIST	SMALLINT )
  SPECIFIC USP_GLOBALPERM_DATA
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
	WITH curr_global AS (
  
	SELECT rol.GRANTEE USERNAME, 
		CASE rol.GRANTEETYPE WHEN 'R' THEN 'DATABASE_ROLE'
		 				    WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
		ELSE NULL END USERTYPE, 
		rol.ROLENAME,
		'GRANT' ACCESSTYPE,
		dbperm.PRIVILAGENAME,
		dbperm.TABLE_TYPE,
		dbperm.SCHEMANAME,
		dbperm.OBJECTNAME,
		dbperm.COLUMNNAME
 	FROM AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_ROLEAUTH rol
  	INNER JOIN (SELECT 	sp.DB_CMDB_NAME, 
						sp.GRANTEE, 
						sp.SNAP_TS,
						CASE sp.GRANTEETYPE 	WHEN 'R' THEN 'DATABASE_ROLE'
												WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
						ELSE NULL END USERTYPE,
						'CONNECT' PRIVILAGENAME, 
						'DATABASE' TABLE_TYPE, 
						'*' SCHEMANAME, 
						'*' OBJECTNAME, 
						'*' COLUMNNAME 
				FROM AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_DBAUTH sp
				WHERE trim(sp.DB_CMDB_NAME) = trim(P_DB_CMDB_NAME)
					AND VARCHAR_FORMAT(sp.SNAP_TS,'DD.MM.YYYY HH24:MI:SS') = TRIM(P_TIMESTAMP)
--					AND  sp.CONNECTAUTH != 'N' -- alle Rollenzuweiseungen, da Connect-Recht immer R_CONNECT hat und diese per Whitelist ausgeblendet wird 
          ) dbperm  
   		ON trim(rol.DB_CMDB_NAME) = trim(dbperm.DB_CMDB_NAME)
   			AND rol.SNAP_TS = dbperm.SNAP_TS
   			AND (rol.GRANTEE = dbperm.GRANTEE OR rol.ROLENAME  = dbperm.GRANTEE)
	WHERE trim(rol.DB_CMDB_NAME) = trim(P_DB_CMDB_NAME)
    	AND VARCHAR_FORMAT(rol.SNAP_TS,'DD.MM.YYYY HH24:MI:SS') = TRIM(P_TIMESTAMP) 
	UNION ALL
	SELECT 	sp.GRANTEE USERNAME, 
			CASE sp.GRANTEETYPE 	WHEN 'R' THEN 'DATABASE_ROLE'
									WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
			ELSE NULL END USERTYPE,
			sp.ROLENAME,
			'GRANT' ACCESSTYPE,
			'CONNECT' PRIVILAGENAME, 
			'DATABASE' TABLE_TYPE, 
			'*' SCHEMANAME, 
			'*' OBJECTNAME, 
			'*' COLUMNNAME
	FROM AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_ROLEAUTH sp
	WHERE trim(sp.DB_CMDB_NAME) = trim(P_DB_CMDB_NAME)
		AND VARCHAR_FORMAT(sp.SNAP_TS,'DD.MM.YYYY HH24:MI:SS') = TRIM(P_TIMESTAMP)
		AND sp.ROLENAME LIKE '%CONNECT%'
	),
	prev_global AS (
  
	SELECT rol.GRANTEE USERNAME, 
		CASE rol.GRANTEETYPE WHEN 'R' THEN 'DATABASE_ROLE'
		 				    WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
		ELSE NULL END USERTYPE, 
		rol.ROLENAME,
		'GRANT' ACCESSTYPE,
		dbperm.PRIVILAGENAME,
		dbperm.TABLE_TYPE,
		dbperm.SCHEMANAME,
		dbperm.OBJECTNAME,
		dbperm.COLUMNNAME
 	FROM AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_ROLEAUTH rol
  	INNER JOIN (SELECT 	sp.DB_CMDB_NAME, 
						sp.GRANTEE, 
						sp.SNAP_TS,
						CASE sp.GRANTEETYPE 	WHEN 'R' THEN 'DATABASE_ROLE'
												WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
						ELSE NULL END USERTYPE,
						'CONNECT' PRIVILAGENAME, 
						'DATABASE' TABLE_TYPE, 
						'*' SCHEMANAME, 
						'*' OBJECTNAME, 
						'*' COLUMNNAME 
				FROM AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_DBAUTH sp
				WHERE trim(sp.DB_CMDB_NAME) = trim(P_DB_CMDB_NAME)
					AND VARCHAR_FORMAT(sp.SNAP_TS,'DD.MM.YYYY HH24:MI:SS') = TRIM(P_TIMESTAMP)
					--					AND  sp.CONNECTAUTH != 'N' -- alle Rollenzuweiseungen, da Connect-Recht immer R_CONNECT hat und diese per Whitelist ausgeblendet wird  
          ) dbperm  
   		ON trim(rol.DB_CMDB_NAME) = trim(dbperm.DB_CMDB_NAME)
   			AND rol.SNAP_TS = dbperm.SNAP_TS
   			AND (rol.GRANTEE = dbperm.GRANTEE OR rol.ROLENAME  = dbperm.GRANTEE)
	WHERE trim(rol.DB_CMDB_NAME) = trim(P_DB_CMDB_NAME)
    	AND VARCHAR_FORMAT(rol.SNAP_TS,'DD.MM.YYYY HH24:MI:SS') = TRIM(P_PREVTIMESTAMP) 
	UNION ALL
	SELECT 	sp.GRANTEE USERNAME, 
			CASE sp.GRANTEETYPE 	WHEN 'R' THEN 'DATABASE_ROLE'
									WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
			ELSE NULL END USERTYPE,
			sp.ROLENAME,
			'GRANT' ACCESSTYPE,
			'CONNECT' PRIVILAGENAME, 
			'DATABASE' TABLE_TYPE, 
			'*' SCHEMANAME, 
			'*' OBJECTNAME, 
			'*' COLUMNNAME
	FROM AUTH_DB2_LUW_REPORT.VW_REPORT_DB2_LUW_ROLEAUTH sp
	WHERE trim(sp.DB_CMDB_NAME) = trim(P_DB_CMDB_NAME)
		AND VARCHAR_FORMAT(sp.SNAP_TS,'DD.MM.YYYY HH24:MI:SS') = TRIM(P_PREVTIMESTAMP)
		AND sp.ROLENAME LIKE '%CONNECT%'
	)
	
	SELECT DISTINCT 
            'Global permission' Global, 
            ISNULL(curr.USERNAME, prev.USERNAME)			            	as username, 
            ISNULL(curr.ROLENAME, prev.ROLENAME)							as rolename,
            ISNULL(curr.SCHEMANAME, prev.SCHEMANAME)						as schemaname,
            ISNULL(curr.TABLE_TYPE, prev.TABLE_TYPE)				    	as table_type,		
            case ISNULL(curr.USERTYPE, prev.USERTYPE)	WHEN 'G' THEN 'DATABASE_GROUP' WHEN 'U' THEN 'DATABASE_USER'
                                                    	when 'R' then 'DATABASE_ROLE'
            else ISNULL(curr.USERTYPE, prev.USERTYPE) end              	as usertype,
            ISNULL(curr.ACCESSTYPE, prev.ACCESSTYPE)						as AccessType,
            ISNULL(curr.PRIVILAGENAME, prev.PRIVILAGENAME)		    		as Privilege,
            ISNULL(curr.OBJECTNAME, prev.OBJECTNAME)				    	as Objectname,
            ISNULL(curr.COLUMNNAME, prev.COLUMNNAME)						as ColumnName,
            case when curr.PRIVILAGENAME is null and prev.PRIVILAGENAME is not null then 'DEL'
                 when prev.PRIVILAGENAME is null and curr.PRIVILAGENAME is not null then 'NEW'
            else 'SAME' end sign_compare
        FROM curr_global curr
        FULL OUTER JOIN prev_global prev 
            ON ISNULL(prev.USERNAME,'')=ISNULL(curr.USERNAME,'') 
            	AND ISNULL(prev.ROLENAME,'')=ISNULL(curr.ROLENAME,'') 
            	AND ISNULL(prev.SCHEMANAME,'')=ISNULL(curr.SCHEMANAME,'') 
            	AND ISNULL(prev.TABLE_TYPE,'')=ISNULL(curr.TABLE_TYPE,'') 
            	AND ISNULL(prev.OBJECTNAME,'')=ISNULL(curr.OBJECTNAME,'')
            	AND ISNULL(prev.COLUMNNAME,'')=ISNULL(curr.COLUMNNAME,'')
            	AND ISNULL(prev.USERTYPE,'')=ISNULL(curr.USERTYPE,'') 
            	and ISNULL(prev.ACCESSTYPE,'')=ISNULL(curr.ACCESSTYPE,'') 
            	and ISNULL(prev.PRIVILAGENAME,'')=ISNULL(curr.PRIVILAGENAME,'')
        WHERE curr.PRIVILAGENAME is not null --without DELETED permission
        	AND (ISNULL(P_WHITELIST,0)=0
                OR (not exists (select 1 from AUTH_DB2_LUW_REPORT.VW_DB2_LUW_ADMINS where USERID = ISNULL(curr.USERNAME, prev.USERNAME) ))
            )
        ORDER BY sign_compare, --strFullInstanceName, 
        username, rolename, table_type, AccessType, Privilege, schemaname, Objectname, ColumnName;

  OPEN cur;
  -- Optional: exception expressions
  -- EXCEPTION 
  -- WHEN { exception-condition } THEN { statement; } ... { statement; } 
  -- ... 
  -- WHEN { exception-condition } THEN { statement; } ... { statement; } 
END