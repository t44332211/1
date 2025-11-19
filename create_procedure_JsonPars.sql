USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE OR ALTER PROCEDURE [MONGODBauditreport].JsonPars
AS
DECLARE @SQLServerInstance nvarchar(255) = 'UNKNOWN'
DECLARE @IDSQLServerInstance bigint 
INSERT INTO [MONGODB].[T_SQLServerInstances] ([strInstanceName])
SELECT @SQLServerInstance [strInstanceName]
WHERE NOT EXISTS (SELECT * FROM [MONGODB].[T_SQLServerInstances]  where [strInstanceName]=@SQLServerInstance)
select  @IDSQLServerInstance = IDSQLServerInstance FROM [MONGODB].[T_SQLServerInstances]  where [strInstanceName]=@SQLServerInstance

DROP TABLE IF EXISTS #json_mongo_access
select t.snapshot_timestamp,
       JSON_VALUE(j.value, '$.id') DBid,
	   JSON_VALUE(j.value, '$.name') DBname,
	   cast(CAST(JSON_VALUE(j.value, '$.created') AS DATETIMEOFFSET) AS DATETIME) DBcreated,
	   JSON_VALUE(roledata.value, '$.user') [user],
	   JSON_VALUE(roles.value, '$.databaseName') [rolename], 
	   JSON_VALUE(roles.value, '$.roleName') [permission],
	   @IDSQLServerInstance		IDSQLServerInstance,
	   @SQLServerInstance		SQLServerInstance
into #json_mongo_access
--from [MONGODB].[JsonImportStaging_access] t
from [IB15_DBVerwaltung_ps59_1].[dbo].[t_ImportJson] t
CROSS APPLY OPENJSON(t.RawJson) j
CROSS APPLY OPENJSON(j.value, '$.roles') roledata
CROSS APPLY OPENJSON(roledata.value, '$.roles') as roles
WHERE FullFileNameJson like '%output_db_access.json%'




--select * from #json_mongo_access

MERGE INTO [MONGODB].[T_SQLDatabases] as target
USING (
		select distinct 
			d.IDSQLServerInstance, 
			d.DBid, 
			d.DBname, 
			d.DBcreated, 
			1 [isOnline]
		from #json_mongo_access d
		--order by 2
) as source
ON target.[IDSQLServerInstance]=source.IDSQLServerInstance 
	AND target.dbid=source.dbid
WHEN MATCHED THEN UPDATE 
	SET target.[strDatabaseName]	= source.DBname
	   ,target.[dtCreateDate]		= source.DBcreated
	   ,target.[isOnline]			= source.[isOnline]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	(IDSQLServerInstance, [dbid], [strDatabaseName], [dtCreateDate], [isOnline])
	values
	(source.IDSQLServerInstance, source.dbid, source.DBname, source.DBcreated, source.[isOnline])
WHEN NOT MATCHED BY SOURCE 
	THEN UPDATE SET target.[isOnline] = 0
;

--select * from [MONGODB].[T_SQLDatabases]

MERGE INTO [MONGODB].[T_SQLDatabasePrincipals] as target
USING (
	select distinct 
		d.IDSQLServerInstance IDSQLServerInstance, 
		db.IDSQLDatabase,
		d.[user] AS [name], 
		'U' AS type, 
		'WINDOWS_USER' AS type_desc,
		0 [is_fixed_role]
	from #json_mongo_access d
	inner join  [MONGODB].[T_SQLDatabases] db
	  on db.IDSQLServerInstance=d.IDSQLServerInstance
	     and db.dbid=d.dbid
	UNION
	select distinct 
		d.IDSQLServerInstance IDSQLServerInstance, 
		db.IDSQLDatabase, 
		d.[rolename] AS [name], 
		'R' AS type, 
		'DATABASE_ROLE' AS type_desc,
		1 [is_fixed_role]
	from #json_mongo_access d
	inner join  [MONGODB].[T_SQLDatabases] db
	  on db.IDSQLServerInstance=d.IDSQLServerInstance
	     and db.dbid=d.dbid
) as source
ON target.IDSQLServerInstance	= source.IDSQLServerInstance 
	AND target.IDSQLDatabase	= source.IDSQLDatabase
	AND target.type				= source.type	
	AND target.name				= source.name
WHEN MATCHED THEN UPDATE 
	SET	target.[is_fixed_role]	= source.[is_fixed_role]
	   ,target.[type_desc]		= source.[type_desc]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	(IDSQLServerInstance, [IDSQLDatabase], [name], [type], [type_desc], [is_fixed_role])
	values
	(source.IDSQLServerInstance, source.IDSQLDatabase, source.[name], source.[type], source.[type_desc], [is_fixed_role])
;

--select * from [MONGODB].[T_SQLDatabasePrincipals]

MERGE INTO [MONGODBaudit].[T_SQLDatabases] as target
using (
select distinct 
		d.IDSQLServerInstance, 
		d.snapshot_timestamp [dtSnapshot], 
		db.IDSQLDatabase, 
		d.DBid, 
		d.DBname, 
		d.DBcreated, 
		1 [isOnline]
from #json_mongo_access d
inner join  [MONGODB].[T_SQLDatabases] db
	  on db.IDSQLServerInstance=d.IDSQLServerInstance
	     and db.dbid=d.dbid
) as source
ON target.[dtSnapshot]=source.[dtSnapshot]
	AND target.[IDSQLServerInstance]= source.IDSQLServerInstance 
	AND target.[IDSQLDatabase]		= source.[IDSQLDatabase]
WHEN MATCHED THEN UPDATE 
	SET target.dbid					= source.dbid 
 	   ,target.[strDatabaseName]	= source.DBname
	   ,target.[dtCreateDate]		= source.DBcreated
	   ,target.[isOnline]			= source.[isOnline]
	   ,target.[dtSnapshot]			= source.[dtSnapshot]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	(IDSQLServerInstance, [dtSnapshot], [IDSQLDatabase], [dbid], [strDatabaseName], [dtCreateDate], [isOnline])
	values
	(source.IDSQLServerInstance, source.[dtSnapshot], source.[IDSQLDatabase], source.dbid, source.DBname, source.DBcreated, source.[isOnline])
WHEN NOT MATCHED BY SOURCE 
	THEN UPDATE SET target.[isOnline] = 0
;

--select * from  [MONGODBaudit].[T_SQLDatabases] 
MERGE INTO [MONGODBaudit].[T_DBPrincipals] as target
USING (
	select distinct  
		d.snapshot_timestamp [dtSnapshot], 
		db.IDSQLDatabase,
		p.principal_id, 
		d.[user] AS [name], 
		'U' AS type, 
		'WINDOWS_USER' AS type_desc,
		0 [is_fixed_role]
	from #json_mongo_access d
	inner join  [MONGODB].[T_SQLDatabases] db
	  on db.IDSQLServerInstance=d.IDSQLServerInstance 
		and db.dbid=d.dbid
	inner join [MONGODB].[T_SQLDatabasePrincipals] p
	  on p.[IDSQLServerInstance]=db.IDSQLServerInstance 
		and p.IDSQLDatabase=db.IDSQLDatabase
	    and p.name=d.[user] and p.[type]='U' 
	UNION
	select distinct 
		d.snapshot_timestamp [dtSnapshot], 
		db.IDSQLDatabase, 
		p.principal_id, 
		d.[rolename] AS [name], 
		'R' AS type, 
		'DATABASE_ROLE' AS type_desc,
		1 [is_fixed_role]
	from #json_mongo_access d
	inner join  [MONGODB].[T_SQLDatabases] db
	  on db.IDSQLServerInstance=d.IDSQLServerInstance  
		AND db.dbid=d.dbid
	inner join [MONGODB].[T_SQLDatabasePrincipals] p
	  on p.[IDSQLServerInstance]=db.IDSQLServerInstance 
		AND p.IDSQLDatabase=db.IDSQLDatabase
	    AND p.name=d.[rolename] 
		AND p.[type]='R'
) as source
ON target.[dtSnapshot]=source.[dtSnapshot] 
	AND target.idDB=source.IDSQLDatabase
	AND target.type=source.type	
	AND target.principal_id=source.principal_id
WHEN MATCHED THEN UPDATE 
	SET  target.[name]			= source.[name]
		,target.[is_fixed_role]	= source.[is_fixed_role]
		,target.[type_desc]		= source.[type_desc]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	([dtSnapshot], [idDB], principal_id, [name], [type], [type_desc], [is_fixed_role])
	values
	(source.[dtSnapshot], source.IDSQLDatabase, source.principal_id, source.[name], source.[type], source.[type_desc], [is_fixed_role])
;

--select * from [MONGODBaudit].[T_DBPrincipals] 
MERGE INTO [MONGODBaudit].[T_DBRoleMembers] as target
USING (
	select distinct 
		d.snapshot_timestamp  [dtSnapshot], 
		db.IDSQLDatabase idDB, 
		p.principal_id [role_principal_id], 
		u.principal_id [member_principal_id]
	from #json_mongo_access d
	inner join [MONGODB].[T_SQLDatabases] db
		on db.IDSQLServerInstance=d.IDSQLServerInstance  
			AND db.dbid=d.dbid
	inner join [MONGODB].[T_SQLDatabasePrincipals] u
		on u.[IDSQLServerInstance]=db.IDSQLServerInstance 
			AND u.IDSQLDatabase=db.IDSQLDatabase
			AND u.name=d.[user] 
			AND u.[type]='U' 
	inner join [MONGODB].[T_SQLDatabasePrincipals] p
		on p.[IDSQLServerInstance]=db.IDSQLServerInstance 
			AND  p.IDSQLDatabase=db.IDSQLDatabase
			AND p.name=d.[rolename] 
			AND p.[type]='R'
) as source
ON target.[dtSnapshot]=source.[dtSnapshot] 
	AND target.idDB					=source.idDB
	AND target.[role_principal_id]	=source.[role_principal_id] 
	AND target.[member_principal_id]=source.[member_principal_id]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	([dtSnapshot], [idDB], [role_principal_id], [member_principal_id])
	values
	(source.[dtSnapshot], source.idDB, source.[role_principal_id], source.[member_principal_id])
;
	  --select *  from #json_mongo_access d where  dbName='AWS-DS-myHealth-7e6b454cb451dd34'
	  --select * from  replace [MONGODB].[T_SQLDatabases] where strDatabaseName='AWS-DS-myHealth-7e6b454cb451dd34'

	  --62de6b1ba7df1054257c9847
	  --62de6b1ba7df1054257c9847
--select * from [MONGODBaudit].[T_DBRoleMembers]
--select * from [MONGODBaudit].[T_DBPrincipals] 
--select * from [MONGODBaudit].[T_DBPermissions]
MERGE INTO [MONGODBaudit].[T_DBPermissions] as target
USING (
	select distinct 
		d.snapshot_timestamp  [dtSnapshot], 
		db.IDSQLDatabase idDB, 
		0 class, 
		'DATABASE' [class_desc],
		u.principal_id		[grantee_principal_id], 
		0 [major_id],
		'CO  ' [type], 
		'CONNECT' [permission_name],		
		'G' [state], 
		'GRANT' [state_desc]
	from #json_mongo_access d
	inner join [MONGODB].[T_SQLDatabases] db
		on db.IDSQLServerInstance=d.IDSQLServerInstance  
			AND db.dbid=d.DBid
	inner join [MONGODB].[T_SQLDatabasePrincipals] u
		on u.[IDSQLServerInstance]=db.IDSQLServerInstance 
			AND u.IDSQLDatabase=db.IDSQLDatabase
			AND u.name=d.[user] 
			AND u.[type]='U' 

	UNION
	select distinct 
		d.snapshot_timestamp  [dtSnapshot], 
		db.IDSQLDatabase idDB, 
		iif(d.[permission]='backup',0,1) class, 
		iif(d.[permission]='backup','DATABASE','OBJECT_OR_COLUMN') [class_desc],
		u.principal_id		[grantee_principal_id],  
		p.principal_id	[major_id],
		iif(d.[permission]='backup','BADB','SL  ') [type], 
		d.[permission] [permission_name],
		'G' [state], 
		'GRANT' [state_desc]
	from #json_mongo_access d
	inner join [MONGODB].[T_SQLDatabases] db
		on db.IDSQLServerInstance=d.IDSQLServerInstance  
			AND db.dbid=d.dbid
	inner join [MONGODB].[T_SQLDatabasePrincipals] u
	    on u.[IDSQLServerInstance]=db.IDSQLServerInstance 
			AND u.IDSQLDatabase=db.IDSQLDatabase
			AND u.[name]=d.[user] 
			AND u.[type] in ('X','U','G')
	inner join [MONGODB].[T_SQLDatabasePrincipals] p
		on p.[IDSQLServerInstance]=db.IDSQLServerInstance 
			AND p.IDSQLDatabase=db.IDSQLDatabase
			AND p.[name]=d.[rolename] 
			AND p.[type]  ='R'
--where db.IDSQLDatabase=1 --and u.principal_id=11 and p.principal_id=0
--d.DBname='AWS-DS-myHealth-7e6b454cb451dd34' and d.[user]='DBuserCompass'
--and u.principal_id=10
) 
as source
ON target.[dtSnapshot]					= source.[dtSnapshot] 
	AND target.[idDB]						= source.[idDB]
	AND target.[class]					= source.[class]
	AND target.[type]						= source.[type]
	AND target.[state]					= source.[state]
	AND target.[grantee_principal_id]	= source.[grantee_principal_id] 
	AND target.[major_id]					= source.[major_id]
	AND target.[permission_name]		= source.[permission_name]
WHEN MATCHED THEN UPDATE
	SET target.[class_desc] = source.[class_desc]
		,target.[state_desc] = source.[state_desc]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	([dtSnapshot], [idDB], [class], [class_desc], [major_id], [grantee_principal_id], [type], [permission_name], [state], [state_desc])
	values
	(source.[dtSnapshot], source.[idDB], source.[class], source.[class_desc], source.[major_id], source.[grantee_principal_id], source.[type], source.[permission_name], source.[state], source.[state_desc])
;

--select * from [MONGODBaudit].[T_DBPermissions]

--federation
DROP TABLE IF EXISTS #json_mongo_federation
SELECT	t.snapshot_timestamp,
		JSON_VALUE(g.value, '$.externalGroupName') externalGroupName,
		JSON_VALUE(g.value, '$.id') id,
		JSON_VALUE(ra.value, '$.groupId') groupId,
		JSON_VALUE(ra.value, '$.orgId') orgId,
		JSON_VALUE(ra.value, '$.role') role,
		@IDSQLServerInstance		IDSQLServerInstance,
	    @SQLServerInstance		SQLServerInstance
into #json_mongo_federation
from [MONGODB].[JsonImportStaging_federation] t
CROSS APPLY OPENJSON(t.RawJson) AS j
CROSS APPLY OPENJSON(t.RawJson, '$.results' ) AS g
CROSS APPLY OPENJSON(g.value, '$.roleAssignments') AS ra
WHERE FullFileNameJson like '%output_federation.json%'



-- federation_principles
DROP TABLE IF EXISTS #federation_principles
;with tt as (
	select distinct 
				js.IDSQLServerInstance,
				db.[IDSQLDatabase],  
				js.externalGroupName as [name], 
				'X' type, 
				'EXTERNAL_GROUP' AS type_desc,
				0 [is_fixed_role]
	from #json_mongo_federation js
	inner join [MONGODB].[T_SQLDatabases] db 
		on db.IDSQLServerInstance=js.IDSQLServerInstance
	UNION  
	select distinct 
				js.IDSQLServerInstance,
				db.[IDSQLDatabase], 
				js.[role] as [name], 
				'G' type, 
				'WINDOWS_GROUP' AS type_desc,
				0 [is_fixed_role]
	from #json_mongo_federation js
	inner join [MONGODB].[T_SQLDatabases] db 
		on db.IDSQLServerInstance=js.IDSQLServerInstance
	WHERE js.orgid is null
	UNION  
	select distinct js.IDSQLServerInstance,
				db.[IDSQLDatabase], 
				js.[role] as [name],  
				'R' type, 
				'DATABASE_ROLE' AS type_desc ,
				0 [is_fixed_role]
	from #json_mongo_federation js
	inner join [MONGODB].[T_SQLDatabases] db 
		on db.IDSQLServerInstance=js.IDSQLServerInstance
	WHERE js.groupid is null 
)
select * into #federation_principles from tt

MERGE INTO [MONGODB].[T_SQLDatabasePrincipals] as target
USING #federation_principles as source
ON target.IDSQLServerInstance	= source.IDSQLServerInstance 
	AND target.IDSQLDatabase	= source.IDSQLDatabase
	AND  target.type			= source.type	
	AND target.name				= source.name
WHEN MATCHED THEN UPDATE 
	SET target.[is_fixed_role]	= source.[is_fixed_role]
		,target.[type_desc]		= source.[type_desc]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	(IDSQLServerInstance, [IDSQLDatabase], [name], [type], [type_desc], [is_fixed_role])
	values
	(source.IDSQLServerInstance, source.IDSQLDatabase, source.[name], source.[type], source.[type_desc], [is_fixed_role])
;

MERGE INTO [MONGODBaudit].[T_DBPrincipals] as target
USING (
	select distinct 
		t.dtSnapshot, 
		f.IDSQLDatabase, 
		f.name, 
		p.principal_id, 
		f.type, 
		f.type_desc, 
		f.is_fixed_role
	from #federation_principles f
	cross join (select distinct js.snapshot_timestamp [dtSnapshot] 
				from #json_mongo_federation js) t
	inner join [MONGODB].[T_SQLDatabasePrincipals] p
		on p.[IDSQLServerInstance]=f.IDSQLServerInstance 
			and p.IDSQLDatabase=f.IDSQLDatabase
			and p.name=f.[name] 
			and p.[type]=f.type
) as source
ON target.[dtSnapshot]=source.[dtSnapshot] 
	AND target.idDB=source.IDSQLDatabase
	AND target.type=source.type	
	AND target.principal_id=source.principal_id
WHEN MATCHED THEN UPDATE 
	SET  target.[name]			= source.[name]
		,target.[is_fixed_role]	= source.[is_fixed_role]
		,target.[type_desc]		= source.[type_desc]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	([dtSnapshot], [idDB], principal_id, [name], [type], [type_desc], [is_fixed_role])
	values
	(source.[dtSnapshot], source.IDSQLDatabase, source.principal_id, source.[name], source.[type], source.[type_desc], [is_fixed_role])
;

MERGE INTO [MONGODBaudit].[T_DBRoleMembers] as target
USING (
	select distinct 
		d.snapshot_timestamp  [dtSnapshot], 
		db.IDSQLDatabase idDB, 
		p.principal_id [role_principal_id], 
		u.principal_id [member_principal_id]
	from #json_mongo_federation d
	inner join [MONGODB].[T_SQLDatabases] db
		on db.IDSQLServerInstance=d.IDSQLServerInstance 
	inner join [MONGODB].[T_SQLDatabasePrincipals] u
		on u.[IDSQLServerInstance]=db.IDSQLServerInstance 
			and u.IDSQLDatabase=db.IDSQLDatabase
			and u.name=d.externalGroupName 
			and u.[type]='X' 
	inner join [MONGODB].[T_SQLDatabasePrincipals] p
		on p.[IDSQLServerInstance]=db.IDSQLServerInstance 
			and p.IDSQLDatabase=db.IDSQLDatabase
			and p.name=d.[role] 
			and p.[type] in ('R','G')
) as source
ON target.[dtSnapshot]					= source.[dtSnapshot] 
	and target.idDB						= source.idDB
	and target.[role_principal_id]		= source.[role_principal_id] 
	and target.[member_principal_id]	= source.[member_principal_id]
WHEN NOT MATCHED BY TARGET THEN INSERT 
	([dtSnapshot], [idDB], [role_principal_id], [member_principal_id])
	values
	(source.[dtSnapshot], source.idDB, source.[role_principal_id], source.[member_principal_id])
;