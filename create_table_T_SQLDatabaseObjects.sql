USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elastic].[T_SQLDatabaseObjects](
	[IDSQLDatabase] [int] NOT NULL,
	[object_name] [sysname] NULL,
	[object_id] [bigint] IDENTITY(1,1) NOT NULL,
	[schema_name] [sysname] NULL,
	[parent_object_id] [int] NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[modify_date] [datetime] NULL
) ON [PRIMARY]
GO


