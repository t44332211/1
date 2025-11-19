USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elasticaudit].[T_DBRoleMembers](
	[dtSnapshot] [smalldatetime] NOT NULL,
	[idDB] [bigint] NOT NULL,
	[role_principal_id] [bigint] NOT NULL,
	[member_principal_id] [bigint] NOT NULL,
 CONSTRAINT [PK_T_DBRoleMembers] PRIMARY KEY CLUSTERED 
(
	[dtSnapshot] ASC,
	[idDB] ASC,
	[role_principal_id] ASC,
	[member_principal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [elasticaudit].[T_DBRoleMembers]  WITH CHECK ADD  CONSTRAINT [FK_T_DBRoleMembers_idDB] FOREIGN KEY([idDB])
REFERENCES [elastic].[T_SQLDatabases] ([IDSQLDatabase])
GO

ALTER TABLE [elasticaudit].[T_DBRoleMembers] CHECK CONSTRAINT [FK_T_DBRoleMembers_idDB]
GO

ALTER TABLE [elasticaudit].[T_DBRoleMembers]  WITH CHECK ADD  CONSTRAINT [FK_T_DBRoleMembers_members] FOREIGN KEY([member_principal_id])
REFERENCES [elastic].[T_SQLDatabasePrincipals] ([principal_id])
GO

ALTER TABLE [elasticaudit].[T_DBRoleMembers] CHECK CONSTRAINT [FK_T_DBRoleMembers_members]
GO


