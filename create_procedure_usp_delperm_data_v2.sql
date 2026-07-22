USE [IB15_DBVerwaltung_ps733]
GO

/****** Object:  StoredProcedure [postgresauditreport].[usp_delperm_data]    Script Date: 21.07.2026 14:06:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [postgresauditreport].[usp_delperm_data_v2]
(
	@Parameters [postgresauditreport].[TT_InputParameters]  READONLY
)
AS
BEGIN

	-- global permissions
	DROP TABLE IF EXISTS #curr_global;
	SELECT	DISTINCT 'Global permission'			AS [Global], 
			iif(dPerm.type_desc='DATABASE_ROLE','', dPerm.username) AS DataBaseUser,
			null	ADGroupLink,
			isnull(dPerm.granted_role,'') AS  RoleName, --DatabaseRole
			dPerm.type_desc as UserType, 
			dPerm.privilege, 
			'GRANT' [PermissionState],
			'*' SchemaName,
			'DATABASE' ObjectType,
			'*' ObjectName, 
			'*' ColumnName
	INTO #curr_global
	FROM @Parameters p
	CROSS APPLY [postgresauditreport].[get_OverviewDBPermissions_v2](p.Datenbankname, convert(smalldatetime,p.timestamp,102)) dPerm 
	WHERE dPerm.privilege = 'CONNECT'
	AND (isnull(p.whitelist,0)=0
					OR NOT EXISTS (select 1 from [postgresaudit].[WhiteList] wl
								  where (wl.[User] is null or (wl.[User]=iif(dPerm.[type_desc]='DATABASE_ROLE','', dPerm.username)))
								  and (wl.DBRole is null or (wl.DBRole=iif(dPerm.[type_desc]='DATABASE_ROLE', dPerm.granted_role,'')))
								  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.privilege))
								    )
								  )
	OPTION (recompile);
	
	DROP TABLE IF EXISTS #prev_global;
	SELECT	DISTINCT 'Global permission'			AS [Global], 
			iif(dPerm.type_desc='DATABASE_ROLE','', dPerm.username) AS DataBaseUser,
			null	ADGroupLink,
			isnull(dPerm.granted_role,'') AS  RoleName, --DatabaseRole
			dPerm.type_desc as UserType, 
			dPerm.privilege, 
			'GRANT' [PermissionState],
			'*' SchemaName,
			'DATABASE' ObjectType,
			'*' ObjectName, 
			'*' ColumnName
	INTO #prev_global
	FROM @Parameters p
	CROSS APPLY [postgresauditreport].[get_OverviewDBPermissions_v2](p.Datenbankname, convert(smalldatetime,p.timestamp_prev,102)) dPerm 
	WHERE dPerm.privilege = 'CONNECT'
	AND (isnull(p.whitelist,0)=0
					OR NOT EXISTS (select 1 from [postgresaudit].[WhiteList] wl
								  where (wl.[User] is null or (wl.[User]=iif(dPerm.[type_desc]='DATABASE_ROLE','', dPerm.username)))
								  and (wl.DBRole is null or (wl.DBRole=iif(dPerm.[type_desc]='DATABASE_ROLE', dPerm.granted_role,'')))
								  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.privilege))
								    )
								  )
	OPTION (recompile);
		
	
	--object
	DROP TABLE IF EXISTS #curr_object;
	SELECT	DISTINCT 'Object permission'			AS [Global], 
			iif(dPerm.type_desc='DATABASE_ROLE','', dPerm.username) AS DataBaseUser,
			null	ADGroupLink,
			isnull(dPerm.granted_role,'') AS  RoleName, --DatabaseRole
			dPerm.type_desc as UserType, 
			dPerm.privilege, 
			'GRANT' [PermissionState],
			'*' SchemaName,
			'DATABASE' ObjectType,
			'*' ObjectName, 
			'*' ColumnName
	INTO #curr_object
	--select dPerm.*
	FROM @Parameters p
	CROSS APPLY [postgresauditreport].[get_OverviewDBPermissions_v2](p.Datenbankname, convert(smalldatetime,p.timestamp,102)) dPerm 
	WHERE trim(p.PersonRole) != 'DataSteward' and dPerm.privilege != 'CONNECT'
	AND (isnull(p.whitelist,0)=0
					OR NOT EXISTS (select 1 from [postgresaudit].[WhiteList] wl
								  where (wl.[User] is null or (wl.[User]=iif(dPerm.[type_desc]='DATABASE_ROLE','', dPerm.username)))
								  and (wl.DBRole is null or (wl.DBRole=iif(dPerm.[type_desc]='DATABASE_ROLE', dPerm.granted_role,'')))
								  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.privilege))
								    )
								  )
	OPTION (recompile);
	
	DROP TABLE IF EXISTS #prev_object;
	SELECT	DISTINCT 'Object permission'			AS [Global], 
			iif(dPerm.type_desc='DATABASE_ROLE','', dPerm.username) AS DataBaseUser,
			null	ADGroupLink,
			isnull(dPerm.granted_role,'') AS  RoleName, --DatabaseRole
			dPerm.type_desc as UserType, 
			dPerm.privilege, 
			'GRANT' [PermissionState],
			'*' SchemaName,
			'DATABASE' ObjectType,
			'*' ObjectName, 
			'*' ColumnName
	INTO #prev_object
	FROM @Parameters p
	CROSS APPLY [postgresauditreport].[get_OverviewDBPermissions_v2](p.Datenbankname, convert(smalldatetime,p.timestamp_prev,102)) dPerm 
	WHERE trim(p.PersonRole) != 'DataSteward' and dPerm.privilege != 'CONNECT'
	AND (isnull(p.whitelist,0)=0
					OR NOT EXISTS (select 1 from [postgresaudit].[WhiteList] wl
								  where (wl.[User] is null or (wl.[User]=iif(dPerm.[type_desc]='DATABASE_ROLE','', dPerm.username)))
								  and (wl.DBRole is null or (wl.DBRole=iif(dPerm.[type_desc]='DATABASE_ROLE', dPerm.granted_role,'')))
								  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.privilege))
								    )
								  )
	OPTION (recompile);
		
	with tt as (
	SELECT DISTINCT 
		'Global permission' [Global], 
		isnull(curr.[DataBaseUser], prev.[DataBaseUser])			as [User], 
		isnull(curr.RoleName, prev.RoleName)						as RoleName,
		isnull(curr.[SchemaName], prev.SchemaName)					as [Schema],
		isnull(curr.[ObjectType], prev.[ObjectType])				as [Type],		
		isnull(curr.[UserType], prev.[UserType])					as [UserType],
		isnull(curr.[PermissionState], prev.[PermissionState])		as [AccessType],
		isnull(curr.[privilege], prev.[privilege])					as [Privilege],
		isnull(curr.ADGroupLink, prev.ADGroupLink)					as ADGroupLink,
		isnull(curr.[ObjectName], prev.[ObjectName])				as [Object],
		isnull(curr.ColumnName, prev.ColumnName)					as ColumnName,
		--prev.strFullInstanceName, prev.Datenbankname, prev.[User], prev.[Object], prev.[Schema], prev.[Type], prev.[User Type], prev.[Access Type], prev.[Privilege],
		case when curr.[privilege] is null and prev.[privilege] is not null then 'DEL'
			 when prev.[privilege] is null and curr.[privilege] is not null then 'NEW'
		else 'SAME' end sign_compare,
		iif(coalesce(curr.[DataBaseUser], prev.[DataBaseUser],'') = '', 1, 0) orderby
	FROM #curr_global curr
	FULL OUTER JOIN #prev_global prev 
		ON isnull(prev.[DataBaseUser],'')=isnull(curr.[DataBaseUser],'') and isnull(prev.RoleName,'')=isnull(curr.RoleName,'') 
		   and isnull(prev.[SchemaName],'')=isnull(curr.[SchemaName],'') and isnull(prev.[ObjectType],'')=isnull(curr.[ObjectType],'') 
		   AND isnull(prev.[ObjectName],'')=isnull(curr.[ObjectName],'')
		   AND isnull(prev.ColumnName,'')=isnull(curr.ColumnName,'')
		   AND isnull(prev.[UserType],'')=isnull(curr.[UserType],'') and isnull(prev.[PermissionState],'')=isnull(curr.[PermissionState],'') 
		   and isnull(prev.[privilege],'')=isnull(curr.[privilege],'')
	WHERE curr.[privilege] is null -- DELETED permission
	
	UNION ALL

	SELECT DISTINCT 
		'Object permission' [Global], 
		isnull(curr.[DataBaseUser], prev.[DataBaseUser])			as [User], 
		isnull(curr.RoleName, prev.RoleName)						as RoleName,
		isnull(curr.[SchemaName], prev.SchemaName)					as [Schema],
		isnull(curr.[ObjectType], prev.[ObjectType])				as [Type],
		isnull(curr.[UserType], prev.[UserType])					as [UserType],
		isnull(curr.[PermissionState], prev.[PermissionState])		as [AccessType],
		isnull(curr.[privilege], prev.[privilege])					as [Privilege],
		isnull(curr.ADGroupLink, prev.ADGroupLink)					as ADGroupLink,
		isnull(curr.[ObjectName], prev.[ObjectName])				as [Object],
		isnull(curr.ColumnName, prev.ColumnName)					as ColumnName,
		--prev.strFullInstanceName, prev.Datenbankname, prev.[User], prev.[Object], prev.[Schema], prev.[Type], prev.[User Type], prev.[Access Type], prev.[Privilege],
		case when curr.[privilege] is null and prev.[privilege] is not null then 'DEL'
			 when prev.[privilege] is null and curr.[privilege] is not null then 'NEW'
		else 'SAME' end sign_compare,
		iif(coalesce(curr.[DataBaseUser], prev.[DataBaseUser],'') = '', 1, 0) orderby
	FROM #curr_object curr
	FULL OUTER JOIN #prev_object prev 
		ON     isnull(prev.[DataBaseUser],'')=isnull(curr.[DataBaseUser],'') and isnull(prev.RoleName,'')=isnull(curr.RoleName,'') 
		   and isnull(prev.[SchemaName],'')=isnull(curr.[SchemaName],'') and isnull(prev.[ObjectType],'')=isnull(curr.[ObjectType],'') 
		   AND isnull(prev.[ObjectName],'')=isnull(curr.[ObjectName],'')
		   AND isnull(prev.ColumnName,'')=isnull(curr.ColumnName,'')
		   AND isnull(prev.[UserType],'')=isnull(curr.[UserType],'') and isnull(prev.[PermissionState],'')=isnull(curr.[PermissionState],'') 
		   and isnull(prev.[privilege],'')=isnull(curr.[privilege],'')
	WHERE curr.[privilege] is null -- DELETED permission
	)
	SELECT [Global], [User], RoleName, [Schema], [Type], [UserType], [AccessType], [Privilege], ADGroupLink, [Object], ColumnName, sign_compare, orderby
	FROM tt
	ORDER BY sign_compare, 
			 orderby, [User], 
			 RoleName, [UserType], [Schema], [Object], ColumnName, [Type], [Privilege], [AccessType]
	OPTION (recompile);	
	
END
GO


