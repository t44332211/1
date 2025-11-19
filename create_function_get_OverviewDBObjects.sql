USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER FUNCTION [elasticauditreport].[get_OverviewDBObjects] (
	@serverName NVARCHAR(max) = NULL --for multiple values
   ,@dbName		NVARCHAR(max) = NULL --for multiple values
   --,@personrole NVARCHAR(max) = NULL  --for multiple values
) RETURNS TABLE
AS
RETURN (
WITH CTE_Overview AS
(
	SELECT	DBO.Datenbankname, 
			DBO.IDSQLServerInstance, 
			DBO.strFullInstanceName, 
			DBO.[strInstanceName],
			DBO.[strSQLServerName],
			DBO.Owner, 
			DBO.Substitute1, 
			DBO.Substitute2, 
			DBO.DataOwner, 
			DBO.DataSteward1, 
			DBO.DataSteward2, 
			DBO.DataSteward3,
			DBO.IDSQLDatabase
	FROM [elasticauditreport].[get_OverviewDatabases_online] (@serverName) AS DBO 
	WHERE (trim(@dbName) IS NULL OR DBO.Datenbankname IN (select trim(value) value from string_split(@dbName,',') where trim(value) is not null))
		AND (1=IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL') --admin
			--1=IS_MEMBER('LAN\GgpAcc-SSISAcc-IB15Verwaltung')--admin
			OR
			(  
				(DBO.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR DBO.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR DBO.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR DBO.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR	DBO.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR	DBO.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR	DBO.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				)
		  )
		 )
)
SELECT	dbo1.dtSnapshot, dbo1.name, dbo1.object_id, dbo1.principal_id, 
		dbo1.[schema_id], --sch.name [schema_name], 
		dbo1.parent_object_id, dbo1.type, dbo1.type_desc, --dbo1.create_date, dbo1.modify_date, 
		--dbo1.is_ms_shipped, dbo1.is_published, dbo1.is_schema_published,
		tbl_dbs.IDSQLServerInstance,  tbl_dbs.strFullInstanceName, tbl_dbs.[strInstanceName], tbl_dbs.[strSQLServerName],
		dbo1.idDB, tbl_dbs.Datenbankname,
		tbl_dbs.Owner, tbl_dbs.Substitute1, tbl_dbs.Substitute2, tbl_dbs.DataOwner, tbl_dbs.DataSteward1, tbl_dbs.DataSteward2, tbl_dbs.DataSteward3
FROM CTE_Overview tbl_dbs 
INNER JOIN [elasticaudit].[T_DBObjects] dbo1 
   ON  tbl_dbs.IDSQLDatabase=dbo1.idDB
)
