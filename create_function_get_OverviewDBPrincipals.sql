USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER FUNCTION [MONGODBauditreport].[get_OverviewDBPrincipals] (
	@serverName NVARCHAR(max) = NULL --for multiple values
   ,@dbName		NVARCHAR(max) = NULL --for multiple values
   --,@personrole NVARCHAR(max) = NULL  --for multiple values
) RETURNS TABLE
AS
RETURN (
SELECT	p1.dtSnapshot, p1.idDB, tbl_dbs.Datenbankname,
		tbl_dbs.IDSQLServerInstance,  tbl_dbs.strFullInstanceName, tbl_dbs.[strInstanceName], tbl_dbs.[strSQLServerName],
		tbl_dbs.Owner, tbl_dbs.Substitute1, tbl_dbs.Substitute2, tbl_dbs.DataOwner, tbl_dbs.DataSteward1, tbl_dbs.DataSteward2, tbl_dbs.DataSteward3,
		p1.name, p1.principal_id, p1.type, p1.type_desc, p1.default_schema_name, 
		p1.create_date, p1.modify_date, p1.owning_principal_id, 
		p1.sid, p1.is_fixed_role, p1.authentication_type, p1.authentication_type_desc --, p1.default_language_lcid, p1.default_language_name, p1.allow_encrypted_value_modifications
FROM [MONGODBaudit].[T_DBPrincipals] p1
CROSS APPLY (select tbl_dbs.Datenbankname, tbl_dbs.IDSQLServerInstance,  tbl_dbs.strFullInstanceName, tbl_dbs.[strInstanceName], tbl_dbs.[strSQLServerName],
					tbl_dbs.Owner, tbl_dbs.Substitute1, tbl_dbs.Substitute2, tbl_dbs.DataOwner, tbl_dbs.DataSteward1, tbl_dbs.DataSteward2, tbl_dbs.DataSteward3
			from [MONGODBauditreport].[get_OverviewDatabases_online] (@serverName) AS tbl_dbs 
			where  tbl_dbs.IDSQLDatabase=p1.idDB
  			AND (trim(@dbName) IS NULL OR tbl_dbs.Datenbankname IN (select trim(value) value from string_split(@dbName,',') where trim(value) is not null))
			AND (1=IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL') --admin
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
			) as tbl_dbs 
)

