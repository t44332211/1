USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER FUNCTION [MONGODBauditreport].[get_OverviewDBPermissions] (
	@serverName NVARCHAR(max) = NULL --for multiple values
   ,@dbName		NVARCHAR(max) = NULL --for multiple values
   --,@personrole NVARCHAR(max) = NULL  --for multiple values
) RETURNS TABLE
AS
RETURN (
SELECT  pr1.dtSnapshot, pr1.idDB, DBO.Datenbankname,
		DBO.IDSQLServerInstance, DBO.strFullInstanceName, DBO.[strInstanceName], DBO.[strSQLServerName],
		DBO.Owner, DBO.Substitute1, DBO.Substitute2, DBO.DataOwner, DBO.DataSteward1, DBO.DataSteward2, DBO.DataSteward3, 
		pr1.class, pr1.class_desc, 
		pr1.major_id, 
		--AllO.name AS major_name, AllO.type AS major_type, AllO.type_desc AS major_type_desc, AllO.schema_name major_schema_name, AllO.column_name,
		pr1.minor_id, 
		--Allm.name AS minor_name, Allm.type AS minor_type, Allm.type_desc AS minor_type_desc, Allm.schema_name minor_schema_name,
		pr1.grantee_principal_id, dPrg.name AS granteeName, dPrg.type AS granteeType, dPrg.type_desc AS granteeType_desc,
		pr1.grantor_principal_id, dPr.name AS grantorName, dPr.type AS grantorType, dPr.type_desc AS grantorType_desc,
		pr1.type, pr1.permission_name, pr1.state, pr1.state_desc,
		coalesce(rolem.RoleName, memb.RoleName, gr.RoleName) RoleName, 
		coalesce(rolem.RoleType, memb.RoleType, gr.RoleType)  RoleType, 
		coalesce(rolem.RoleType_desc, memb.RoleType_desc, gr.RoleType_desc) RoleTypeDesc,
		coalesce(rolem.role_principal_id, memb.role_principal_id, gr.role_principal_id) role_principal_id,
		coalesce(rolem.member_principal_id,  memb.member_principal_id, gr.member_principal_id) member_principal_id,
		coalesce(rolem.MemberName, memb.MemberName, gr.MemberName) MemberName,  
		coalesce(rolem.MemberType, memb.MemberType, gr.MemberType) MemberType,  
		coalesce(rolem.MemberType_desc, memb.MemberType_desc, gr.MemberType_desc) MemberTypeDesc
FROM [MONGODBaudit].[T_DBPermissions] pr1
CROSS APPLY (select tbl_dbs.Datenbankname, tbl_dbs.IDSQLServerInstance,  tbl_dbs.strFullInstanceName, tbl_dbs.[strInstanceName], tbl_dbs.[strSQLServerName],
					tbl_dbs.Owner, tbl_dbs.Substitute1, tbl_dbs.Substitute2, tbl_dbs.DataOwner, tbl_dbs.DataSteward1, tbl_dbs.DataSteward2, tbl_dbs.DataSteward3
			from [MONGODBauditreport].[get_OverviewDatabases_online] (@serverName) AS tbl_dbs 
			where  tbl_dbs.IDSQLDatabase=pr1.idDB
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
			) as DBO 
CROSS APPLY (select dPrg.name, dPrg.type, dPrg.type_desc
             from [MONGODBauditreport].[get_OverviewDBPrincipals] (@serverName, @dbName) dPrg
             where dPrg.dtSnapshot=pr1.dtSnapshot AND dPrg.idDB=pr1.idDB AND dPrg.principal_id=pr1.grantee_principal_id
			 ) AS dPrg
OUTER APPLY (select dPr.name, dPr.type, dPr.type_desc
             from [MONGODBauditreport].[get_OverviewDBPrincipals] (@serverName, @dbName) dPr
			 where dPr.dtSnapshot=pr1.dtSnapshot AND dPr.idDB=pr1.idDB AND dPr.principal_id=pr1.grantor_principal_id
			 ) dPr
--OUTER APPLY (select  AllO.name, AllO.type, AllO.type_desc, AllO.schema_name, c.name column_name
--			 from [mssqlauditreport].[get_OverviewDBObjects] (@serverName, @dbName) AllO
--			 left join mssqlaudit.T_DBColumns c 
--				on c.dtSnapshot= AllO.dtSnapshot and c.idDB=AllO.idDB and c.object_id=AllO.object_id
--			 where AllO.dtSnapshot=pr1.dtSnapshot AND AllO.idDB=pr1.idDB AND AllO.object_id=pr1.major_id
--			 ) AllO
--OUTER APPLY (select  Allm.name, Allm.type, Allm.type_desc, Allm.schema_name
--			 from [mssqlauditreport].[get_OverviewDBObjects] (@serverName, @dbName) Allm
--			 where Allm.dtSnapshot=pr1.dtSnapshot AND Allm.idDB=pr1.idDB AND Allm.object_id=pr1.minor_id
--			 ) Allm
OUTER APPLY (select rm.member_principal_id, rm.MemberName, rm.MemberType, rm.MemberType_desc,
			        rm.role_principal_id, rm.RoleName, rm.RoleType, rm.RoleType_desc
			 from [MONGODBauditreport].[get_OverviewDBRoleMembers] (@serverName,@dbName) rm			 
			 where  rm.dtSnapshot=pr1.dtSnapshot and rm.idDB=pr1.idDB 
			   and rm.role_principal_id=iif(dPrg.type_desc in ('DATABASE_ROLE'), pr1.grantee_principal_id, null)
			) rolem
OUTER APPLY (select rm.member_principal_id, rm.MemberName, rm.MemberType, rm.MemberType_desc,
			        rm.role_principal_id, rm.RoleName, rm.RoleType, rm.RoleType_desc
			 from [MONGODBauditreport].[get_OverviewDBRoleMembers] (@serverName,@dbName) rm			 
			 where  rm.dtSnapshot=pr1.dtSnapshot and rm.idDB=pr1.idDB 
			   and rm.member_principal_id=iif(dPrg.type_desc not in ('DATABASE_ROLE'), pr1.grantee_principal_id, null)
			) memb	
OUTER APPLY (select rm.member_principal_id, rm.MemberName, rm.MemberType, rm.MemberType_desc,
			        rm.role_principal_id, rm.RoleName, rm.RoleType, rm.RoleType_desc
			 from [MONGODBauditreport].[get_OverviewDBRoleMembers] (@serverName,@dbName) rm			 
			 where  rm.dtSnapshot=pr1.dtSnapshot and rm.idDB=pr1.idDB 
			   and rm.member_principal_id=pr1.grantee_principal_id
			) gr	
)
