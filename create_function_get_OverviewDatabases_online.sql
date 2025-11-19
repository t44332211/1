USE [IB15_DBVerwaltung_ps59_1]
GO

--CREATE SCHEMA [elasticauditreport]
CREATE OR ALTER FUNCTION [elasticauditreport].[get_OverviewDatabases_online] (
	@serverName  NVARCHAR(max)  = NULL --for multiple values
	--,@personrole NVARCHAR(max)  = NULL --for multiple values
) RETURNS TABLE
AS
RETURN (
SELECT      tbl_dbs.IDSQLDatabase, tbl_dbs.strDatabaseName AS Datenbankname, --tbl_dbs.intDBSize AS Groesse, 
			tbl_inst.IDSQLServer, tbl_inst.strPhysicalServername,
			tbl_inst.IDSQLServerInstance, tbl_inst.strInstanceName, 
			-- tbl_inst.bFachtest, 
			SUBSTRING(tbl_inst.strInstanceName, 0, CHARINDEX('.', tbl_inst.strInstanceName)) AS strSQLServerName, 
			tbl_inst.strInstanceName AS strFullInstanceName, 
			--tbl_dbs.tableCount, tbl_dbs.indexCount, tbl_dbs.dataSizeMB, tbl_dbs.logSizeMB, 
			--tbl_dbs.reservedPageCount, tbl_dbs.indexPageCount, tbl_dbs.dataPageCount, tbl_dbs.unusedPageCount, tbl_dbs.Application, tbl_inst.strBuild, 
			--tbl_dbs.SLA, tbl_dbs.[7x24], tbl_dbs.WAF, tbl_dbs.WAFPrio, tbl_dbs.SBK, tbl_dbs.ClientAccess, tbl_dbs.DeveloperAccess, 
			tbl_dbs.Owner, tbl_dbs.Substitute1, tbl_dbs.Substitute2, tbl_dbs.DataOwner, tbl_dbs.DataSteward1, tbl_dbs.DataSteward2, tbl_dbs.DataSteward3
FROM elasticaudit.T_SQLServerInstances AS tbl_inst 
	--ON tbl_serv.IDSQLServer = tbl_inst.IDSQLServer 
LEFT OUTER JOIN elasticaudit.T_SQLDatabases AS tbl_dbs 
	ON tbl_inst.IDSQLServerInstance = tbl_dbs.IDSQLServerInstance

WHERE        (tbl_dbs.strDatabaseName IS NOT NULL) AND (tbl_dbs.isOnline = 1)
AND ( trim(@serverName) IS NULL 
	  OR (tbl_inst.strInstanceName) IN (select trim(value) value from string_split(@serverName,',') where trim(value) is not null))
	AND (1=IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL') --admin
		--1=IS_MEMBER('LAN\GgpAcc-SSISAcc-IB15Verwaltung') 
		OR
		(  
			(tbl_dbs.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR tbl_dbs.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR tbl_dbs.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR tbl_dbs.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR	tbl_dbs.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR	tbl_dbs.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR	tbl_dbs.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			)
	  )
	 )
	)
