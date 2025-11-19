USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER PROCEDURE [elasticauditreport].[usp_objectperm_data]
(
	@Parameters [elasticauditreport].[TT_InputParameters]  READONLY
)
AS
BEGIN

	--object permission
	DROP TABLE IF EXISTS #curr_object;
	SELECT	DISTINCT 'Object permission'			AS [Global],
			isnull(dPerm.MemberName,dPerm.granteeName) AS DataBaseUser,
			iif(isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc) !='WINDOWS_GROUP','',
				'https://clima.lan.huk-coburg.de/GroupInfo2/Home/Members/'+ substring(isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc),charindex('\',isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc))+1,len(isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc)))) ADGroupLink,				
			isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc) as UserType,
			dPerm.RoleName, --DatabaseRole
			dPerm.permission_name, 
			dPerm.PermissionState, 
			'*' SchemaName,
			isnull(dPerm.major_type_desc,'DATABASE') ObjectType,
			isnull(dPerm.major_name,'*') ObjectName, 
			'*' ColumnName
	INTO #curr_object
	FROM @Parameters p
	CROSS APPLY (	select dPerm.grantee_principal_id, dPerm.granteeName, dPerm.granteeType, dPerm.granteeType_desc,
						 dPerm.major_id, dPerm.major_name, dPerm.major_type, dPerm.major_type_desc, --dPerm.major_schema_name,
						 dPerm.permission_name, dPerm.state_desc PermissionState, --dPerm.column_name,
						 dPerm.MemberName, dPerm.MemberType, dPerm.MemberTypeDesc, dPerm.member_principal_id,
						 dPerm.RoleName, dPerm.RoleType, dPerm.RoleTypeDesc, dPerm.role_principal_id
					from [elasticauditreport].[get_OverviewDBPermissions] (p.strFullInstanceName, p.Datenbankname) dPerm 
					WHERE convert(smalldatetime,p.timestamp,102) = dPerm.dtSnapshot
					  --AND dPerm.granteeType='G'
					  AND trim(p.PersonRole) != 'DataSteward'
					  AND isnull(dPerm.permission_name,'') != 'CONNECT'
					  AND (isnull(p.whitelist,0)=0
							OR NOT EXISTS (select 1 from [elasticauditreport].[vOverview_WhiteList] wl
									   where (wl.[User] is null or (wl.[User]=dPerm.MemberName))
									  and (wl.DBRole is null or (wl.DBRole=dPerm.RoleName))
									  and (wl.Zugriff is null or (wl.Zugriff=dPerm.state_desc))
									  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.permission_name))
									  and (wl.Objecktyp is null or (wl.Objecktyp=isnull(dPerm.major_type_desc,'DATABASE') ))
									  and (wl.[Schema] is null or (wl.[Schema]  = '*'))
									  and (wl.Objecktname is null or (wl.Objecktname=isnull(dPerm.major_name,'*')))
									  and (wl.Spalte is null or (wl.Spalte='*'
									  )
							)
						)
					)
	) dPerm
	OPTION (recompile);
	
	DROP TABLE IF EXISTS #prev_object;
		SELECT	DISTINCT 'Object permission'			AS [Global],
			isnull(dPerm.MemberName,dPerm.granteeName) AS DataBaseUser,
			iif(isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc) !='WINDOWS_GROUP','',
				'https://clima.lan.huk-coburg.de/GroupInfo2/Home/Members/'+ substring(isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc),charindex('\',isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc))+1,len(isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc)))) ADGroupLink,				
			isnull(dPerm.MemberTypeDesc, dPerm.granteeType_desc) as UserType,
			dPerm.RoleName, --DatabaseRole
			dPerm.permission_name, 
			dPerm.PermissionState, 
			'*' SchemaName,
			isnull(dPerm.major_type_desc,'DATABASE') ObjectType,
			isnull(dPerm.major_name,'*') ObjectName, 
			'*' ColumnName
	INTO #prev_object
	FROM @Parameters p
	CROSS APPLY (   select   dPerm.grantee_principal_id, dPerm.granteeName, dPerm.granteeType, dPerm.granteeType_desc,
							 dPerm.major_id, dPerm.major_name, dPerm.major_type, dPerm.major_type_desc, --dPerm.major_schema_name,
							 dPerm.permission_name, dPerm.state_desc PermissionState, --dPerm.column_name,
							 dPerm.MemberName, dPerm.MemberType, dPerm.MemberTypeDesc, dPerm. member_principal_id,
							 dPerm.RoleName, dPerm.RoleType, dPerm.RoleTypeDesc, dPerm.role_principal_id
					from [elasticauditreport].[get_OverviewDBPermissions] (p.strFullInstanceName, p.Datenbankname) dPerm 
					WHERE convert(smalldatetime,p.timestamp_prev,102) = dPerm.dtSnapshot
					  --AND dPerm.granteeType='G'
					  AND trim(p.PersonRole) != 'DataSteward'
					  AND isnull(dPerm.permission_name,'') != 'CONNECT'
					  AND (isnull(p.whitelist,0)=0
							OR NOT EXISTS (select 1 from [elasticauditreport].[vOverview_WhiteList] wl
									   where (wl.[User] is null or (wl.[User]=dPerm.MemberName))
									  and (wl.DBRole is null or (wl.DBRole=dPerm.RoleName))
									  and (wl.Zugriff is null or (wl.Zugriff=dPerm.state_desc))
									  and (wl.Berechtgung is null or (wl.Berechtgung=dPerm.permission_name))
									  and (wl.Objecktyp is null or (wl.Objecktyp=isnull(dPerm.major_type_desc,'DATABASE') ))
									  and (wl.[Schema] is null or (wl.[Schema]  = '*'))
									  and (wl.Objecktname is null or (wl.Objecktname=isnull(dPerm.major_name,'*')))
									  and (wl.Spalte is null or (wl.Spalte='*'
									  )
							)
						)
					)
	) dPerm
	OPTION (recompile);
	
		
	SELECT DISTINCT --curr.grantee_principal_id,
		'Object permission' [Global], 
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
	FROM #curr_object curr
	FULL OUTER JOIN #prev_object prev 
		ON     isnull(prev.[DataBaseUser],'')=isnull(curr.[DataBaseUser],'') and isnull(prev.RoleName,'')=isnull(curr.RoleName,'') 
		   and isnull(prev.[SchemaName],'')=isnull(curr.[SchemaName],'') and isnull(prev.[ObjectType],'')=isnull(curr.[ObjectType],'') 
		   AND isnull(prev.[ObjectName],'')=isnull(curr.[ObjectName],'')
		   AND isnull(prev.ColumnName,'')=isnull(curr.ColumnName,'')
		   AND isnull(prev.[UserType],'')=isnull(curr.[UserType],'') and isnull(prev.[PermissionState],'')=isnull(curr.[PermissionState],'') 
		   and isnull(prev.[permission_name],'')=isnull(curr.[permission_name],'')
	WHERE curr.[permission_name] is not null --without DELETED permission
	ORDER BY sign_compare, [User], RoleName, [Type], [UserType], [AccessType], [Privilege], [Schema], [Object], ColumnName
	OPTION (recompile);

	
END