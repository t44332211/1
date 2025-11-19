USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elasticaudit].[T_DBPermissions](
	[dtSnapshot] [smalldatetime] NOT NULL,
	[idDB] [bigint] NOT NULL,
	[class] [tinyint] NOT NULL,
	[class_desc] [nvarchar](60) NULL,
	[major_id] [bigint] NOT NULL,
	[minor_id] [bigint] NULL,
	[grantee_principal_id] [bigint] NOT NULL,
	[grantor_principal_id] [bigint] NULL,
	[type] [char](4) NOT NULL,
	[permission_name] [nvarchar](1000) NOT NULL,
	[state] [char](1) NOT NULL,
	[state_desc] [nvarchar](60) NULL,
 CONSTRAINT [PK_T_DBPermissions] PRIMARY KEY CLUSTERED 
(
	[dtSnapshot] ASC,
	[idDB] ASC,
	[class] ASC,
	[major_id] ASC,
	[grantee_principal_id] ASC,
	[type] ASC,
	[state] ASC,
	[permission_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [elasticaudit].[T_DBPermissions]  WITH CHECK ADD  CONSTRAINT [FK_T_DBPermissions_grantee] FOREIGN KEY([grantee_principal_id])
REFERENCES [elastic].[T_SQLDatabasePrincipals] ([principal_id])
GO

ALTER TABLE [elasticaudit].[T_DBPermissions] CHECK CONSTRAINT [FK_T_DBPermissions_grantee]
GO

ALTER TABLE [elasticaudit].[T_DBPermissions]  WITH CHECK ADD  CONSTRAINT [FK_T_DBPermissions_grantor] FOREIGN KEY([grantor_principal_id])
REFERENCES [elastic].[T_SQLDatabasePrincipals] ([principal_id])
GO

ALTER TABLE [elasticaudit].[T_DBPermissions] CHECK CONSTRAINT [FK_T_DBPermissions_grantor]
GO

ALTER TABLE [elasticaudit].[T_DBPermissions]  WITH CHECK ADD  CONSTRAINT [FK_T_DBPermissions_idDB] FOREIGN KEY([idDB])
REFERENCES [elastic].[T_SQLDatabases] ([IDSQLDatabase])
GO

ALTER TABLE [elasticaudit].[T_DBPermissions] CHECK CONSTRAINT [FK_T_DBPermissions_idDB]
GO


