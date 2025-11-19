USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elasticaudit].[T_DBObjects](
	[dtSnapshot] [smalldatetime] NOT NULL,
	[idDB] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[object_id] [int] NULL,
	[principal_id] [int] NULL,
	[schema_id] [int] NULL,
	[parent_object_id] [int] NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NULL,
	[modify_date] [datetime] NULL,
	[is_ms_shipped] [bit] NULL,
	[is_published] [bit] NULL,
	[is_schema_published] [bit] NULL
) ON [PRIMARY]
GO


