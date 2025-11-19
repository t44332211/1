USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elastic].[T_SQLDatabasePrincipals](
	[principal_id] [bigint] NOT NULL,
	[IDSQLServerInstance] [bigint] NOT NULL,
	[IDSQLDatabase] [bigint] NOT NULL,
	[name] [nvarchar](512) NOT NULL,
	[type] [char](1) NOT NULL,
	[type_desc] [nvarchar](60) NULL,
	[default_schema_name] [sysname] NULL,
	[create_date] [datetime] NULL,
	[modify_date] [datetime] NULL,
	[owning_principal_id] [int] NULL,
	[sid] [varbinary](85) NULL,
	[is_fixed_role] [bit] NULL,
 CONSTRAINT [PK_T_SQLDatabasePrincipals] PRIMARY KEY CLUSTERED 
(
	[principal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [elastic].[T_SQLDatabasePrincipals] ADD  CONSTRAINT [DF__SQLDatabasePrincipals_principle_id]  DEFAULT (NEXT VALUE FOR [elastic].[HSequence_principle_id]) FOR [principal_id]
GO

ALTER TABLE [elastic].[T_SQLDatabasePrincipals]  WITH CHECK ADD  CONSTRAINT [FK_T_SQLDatabasePrincipals_IDSQLDatabase] FOREIGN KEY([IDSQLDatabase])
REFERENCES [elastic].[T_SQLDatabases] ([IDSQLDatabase])
GO

ALTER TABLE [elastic].[T_SQLDatabasePrincipals] CHECK CONSTRAINT [FK_T_SQLDatabasePrincipals_IDSQLDatabase]
GO


