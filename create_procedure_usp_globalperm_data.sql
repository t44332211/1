USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER PROCEDURE [MONGODBauditreport].[usp_globalperm_data]
(
	@Parameters [MONGODBauditreport].[TT_InputParameters]  READONLY
)
AS
BEGIN

	-- global permissions
	DROP TABLE IF EXISTS #curr_global;
	SELECT	DISTINCT 'Global permission'			AS [Global], --dPr.principal_id,
			--dPrg.dtSnapshot, dPrg.idDB,
			iif(dPerm.granteeType_desc='DATABASE_ROLE','', dPerm.granteeName) AS DataBaseUser,
			iif(dPerm.granteeType_desc='DATABASE_ROLE','',
				'https://clima.lan.huk-coburg.de/GroupInfo2/Home/Members/'+ substring(dPerm.granteeName,charindex('\',dPerm.granteeName)+1,len(dPerm.granteeName))) ADGroupLink,	
			--vDBs.Datenbankname, vDBs.strFullInstanceName,
			iif(dPerm.granteeType_desc='DATABASE_ROLE', dPerm.granteeName,'') AS  RoleName, --DatabaseRole
			dPerm.granteeType_desc as UserType, --dprg.type_desc
			--dPr.default_schema_name, 
			dPerm.permission_name, dPerm.PermissionState, 
			'*' SchemaName,
			'DATABASE' ObjectType,
			'*' ObjectName, 
			'*' ColumnName
	INTO #curr_global
	FROM @Parameters p
	CROSS APPLY (select dPerm.grantee_principal_id, dPerm.granteeName, dPerm.granteeType, dPerm.granteeType_desc,
						 dPerm.major_id, dPerm.permission_name, dPerm.state_desc PermissionState
				from [MONGODBauditreport].[get_OverviewDBPermissions] (p.strFullInstanceName, p.Datenbankname) dPerm 
				where  convert(smalldatetime,p.timestamp,102) = dPerm.dtSnapshot
				AND NOT (dPerm.granteeName = 'public' AND dPerm.granteeType_desc = 'DATABASE_ROLE' AND  dPerm.state_desc = 'GRANT')
				AND dPerm.permission_name = 'CONNECT'
				AND (isnull(p.whitelist,0)=0
					OR NOT EXISTS (select 1 from [MONGODBauditreport].[vOverview_WhiteList] wl
								  where (wl.[User] is null or (wl.[User]=iif(dPerm.granteeType_desc='DATABASE_ROLE','', dPerm.granteeName)))
								  and (wl.DBRole is null or (wl.DBRole=iif(dPerm.granteeType_desc='DATABASE_ROLE', dPerm.granteeName,'')))
								  and (wl.Zugriff is null or (wl.Zugriff=dPerm.state_desc))
								  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.permission_name))
								  and (wl.Objecktyp is null or (wl.Objecktyp='DATABASE' ))
								  and (wl.[Schema] is null or (wl.[Schema]  = '*'))
								  and (wl.Objecktname is null or (wl.Objecktname='*'))
								  and (wl.Spalte is null or (wl.Spalte='*' ))
								  )
					)
			) dPerm
	OPTION (recompile);
	
	DROP TABLE IF EXISTS #prev_global;
	SELECT	DISTINCT 'Global permission'			AS [Global], --dPr.principal_id,
			--dPrg.dtSnapshot, dPrg.idDB,
			iif(dPerm.granteeType_desc='DATABASE_ROLE','', dPerm.granteeName) AS DataBaseUser,
			iif(dPerm.granteeType_desc='DATABASE_ROLE','',
				'https://clima.lan.huk-coburg.de/GroupInfo2/Home/Members/'+ substring(dPerm.granteeName,charindex('\',dPerm.granteeName)+1,len(dPerm.granteeName))) ADGroupLink,	
			--vDBs.Datenbankname, vDBs.strFullInstanceName,
			iif(dPerm.granteeType_desc='DATABASE_ROLE', dPerm.granteeName,'') AS  RoleName, --DatabaseRole
			dPerm.granteeType_desc as UserType, --dprg.type_desc
			--dPr.default_schema_name, 
			dPerm.permission_name, dPerm.PermissionState, 
			'*' SchemaName,
			'DATABASE' ObjectType,
			'*' ObjectName, 
			'*' ColumnName
	INTO #prev_global
	FROM @Parameters p
	CROSS APPLY  (	select dPerm.grantee_principal_id, dPerm.granteeName, dPerm.granteeType, dPerm.granteeType_desc,
						 dPerm.major_id, dPerm.permission_name, dPerm.state_desc PermissionState
					from [MONGODBauditreport].[get_OverviewDBPermissions] (p.strFullInstanceName, p.Datenbankname) dPerm 
					WHERE  convert(smalldatetime,p.timestamp_prev,102) = dPerm.dtSnapshot
						AND NOT (dPerm.granteeName = 'public' AND dPerm.granteeType_desc = 'DATABASE_ROLE' AND  dPerm.state_desc = 'GRANT')
						AND dPerm.permission_name = 'CONNECT'
						AND (isnull(p.whitelist,0)=0
							OR NOT EXISTS (select 1 from [MONGODBauditreport].[vOverview_WhiteList] wl
										  where (wl.[User] is null or (wl.[User]=iif(dPerm.granteeType_desc='DATABASE_ROLE','', dPerm.granteeName)))
										  and (wl.DBRole is null or (wl.DBRole=iif(dPerm.granteeType_desc='DATABASE_ROLE', dPerm.granteeName,'')))
										  and (wl.Zugriff is null or (wl.Zugriff=dPerm.state_desc))
										  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.permission_name))
										  and (wl.Objecktyp is null or (wl.Objecktyp='DATABASE' ))
										  and (wl.[Schema] is null or (wl.[Schema]  = '*'))
										  and (wl.Objecktname is null or (wl.Objecktname='*'))
										  and (wl.Spalte is null or (wl.Spalte='*' ))
										  )
							)
			) dPerm
	OPTION (recompile);
		
	SELECT DISTINCT --curr.grantee_principal_id,
		'Global permission' [Global], 
		--isnull(curr.strFullInstanceName, prev.strFullInstanceName)	as strFullInstanceName, 
		--isnull(curr.Datenbankname, prev.Datenbankname)				as Datenbankname,
		isnull(curr.[DataBaseUser], prev.[DataBaseUser])			as [User], 
		isnull(curr.RoleName, prev.RoleName)						as RoleName,
		isnull(curr.[SchemaName], prev.SchemaName)					as [Schema],
		isnull(curr.[ObjectType], prev.[ObjectType])				as [Type],		
		isnull(curr.[UserType], prev.[UserType])					as [UserType],
		isnull(curr.[PermissionState], prev.[PermissionState])		as [AccessType],
		isnull(curr.[permission_name], prev.[permission_name])		as [Privilege],
		isnull(curr.ADGroupLink, prev.ADGroupLink)					as ADGroupLink,
		isnull(curr.[ObjectName], prev.[ObjectName])				as [Object],
		isnull(curr.ColumnName, prev.ColumnName)					as ColumnName,
		--prev.strFullInstanceName, prev.Datenbankname, prev.[User], prev.[Object], prev.[Schema], prev.[Type], prev.[User Type], prev.[Access Type], prev.[Privilege],
		case when curr.[permission_name] is null and prev.[permission_name] is not null then 'DEL'
			 when prev.[permission_name] is null and curr.[permission_name] is not null then 'NEW'
		else 'SAME' end sign_compare
	FROM #curr_global curr
	FULL OUTER JOIN #prev_global prev 
		ON isnull(prev.[DataBaseUser],'')=isnull(curr.[DataBaseUser],'') and isnull(prev.RoleName,'')=isnull(curr.RoleName,'') 
		   and isnull(prev.[SchemaName],'')=isnull(curr.[SchemaName],'') and isnull(prev.[ObjectType],'')=isnull(curr.[ObjectType],'') 
		   AND isnull(prev.[ObjectName],'')=isnull(curr.[ObjectName],'')
		   AND isnull(prev.ColumnName,'')=isnull(curr.ColumnName,'')
		   AND isnull(prev.[UserType],'')=isnull(curr.[UserType],'') and isnull(prev.[PermissionState],'')=isnull(curr.[PermissionState],'') 
		   and isnull(prev.[permission_name],'')=isnull(curr.[permission_name],'')
	WHERE curr.permission_name is not null --without DELETED permission
	ORDER BY sign_compare, --strFullInstanceName, 
	[User], RoleName, [Type], [UserType], [AccessType], [Privilege], [Schema], [Object], ColumnName
	OPTION (recompile); 


END
