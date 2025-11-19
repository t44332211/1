USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elasticaudit].[T_DBPrincipals](
	[dtSnapshot] [smalldatetime] NOT NULL,
	[idDB] [bigint] NOT NULL,
	[name] [nvarchar](512) NOT NULL,
	[principal_id] [bigint] NOT NULL,
	[type] [char](1) NOT NULL,
	[type_desc] [nvarchar](60) NULL,
	[default_schema_name] [sysname] NULL,
	[create_date] [datetime] NULL,
	[modify_date] [datetime] NULL,
	[owning_principal_id] [int] NULL,
	[sid] [varbinary](85) NULL,
	[is_fixed_role] [bit] NOT NULL,
	[authentication_type] [int] NULL,
	[authentication_type_desc] [nvarchar](60) NULL,
	[default_language_name] [sysname] NULL,
	[default_language_lcid] [int] NULL,
	[allow_encrypted_value_modifications] [bit] NULL,
 CONSTRAINT [PK_T_DBPrincipals] PRIMARY KEY CLUSTERED 
(
	[dtSnapshot] ASC,
	[idDB] ASC,
	[principal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [elasticaudit].[T_DBPrincipals]  WITH CHECK ADD  CONSTRAINT [FK_T_DBPrincipals_principle_id] FOREIGN KEY([principal_id])
REFERENCES [elastic].[T_SQLDatabasePrincipals] ([principal_id])
GO

ALTER TABLE [elasticaudit].[T_DBPrincipals] CHECK CONSTRAINT [FK_T_DBPrincipals_principle_id]
GO

ALTER TABLE [elasticaudit].[T_DBPrincipals]  WITH CHECK ADD  CONSTRAINT [FK_T_SQLDatabasePrincipals_idDB] FOREIGN KEY([idDB])
REFERENCES [elastic].[T_SQLDatabases] ([IDSQLDatabase])
GO

ALTER TABLE [elasticaudit].[T_DBPrincipals] CHECK CONSTRAINT [FK_T_SQLDatabasePrincipals_idDB]
GO


