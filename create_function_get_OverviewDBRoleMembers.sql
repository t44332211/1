USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER FUNCTION [MONGODBauditreport].[get_OverviewDBRoleMembers] (
	@serverName NVARCHAR(max) = NULL --for multiple values
   ,@dbName		NVARCHAR(max) = NULL --for multiple values
   --,@personrole NVARCHAR(max) = NULL  --for multiple values
) RETURNS TABLE
AS
RETURN (
SELECT  pr1.[dtSnapshot], pr1.[idDB], DBO.Datenbankname,
		DBO.IDSQLServerInstance, DBO.strFullInstanceName, DBO.[strInstanceName], DBO.[strSQLServerName],
		DBO.Owner, DBO.Substitute1, DBO.Substitute2, DBO.DataOwner, DBO.DataSteward1, DBO.DataSteward2, DBO.DataSteward3,
		pr1.[role_principal_id], dPrg.name AS RoleName, dPrg.type AS RoleType, dPrg.type_desc AS RoleType_desc,
		pr1.[member_principal_id], dPr.name AS MemberName, dPr.type AS MemberType, dPr.type_desc AS MemberType_desc
FROM [MONGODBaudit].[T_DBRoleMembers] pr1
INNER JOIN [MONGODBauditreport].[get_OverviewDatabases_online] (@serverName) AS DBO 
  ON DBO.IDSQLDatabase=pr1.idDB
  	AND (trim(@dbName) IS NULL OR DBO.Datenbankname IN (select trim(value) value from string_split(@dbName,',') where trim(value) is not null))
	AND (1=IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL') --admin
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
LEFT JOIN [MONGODBauditreport].[get_OverviewDBPrincipals] (@serverName, @dbName) dPrg
  ON dPrg.dtSnapshot=pr1.dtSnapshot AND dPrg.idDB=pr1.idDB AND dPrg.principal_id=pr1.role_principal_id
LEFT JOIN [MONGODBauditreport].[get_OverviewDBPrincipals] (@serverName, @dbName) dPr
  ON dPr.dtSnapshot=pr1.dtSnapshot AND dPr.idDB=pr1.idDB AND dPr.principal_id=pr1.member_principal_id
)
