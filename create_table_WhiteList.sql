USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elasticauditreport].[WhiteList](
	[User] [nvarchar](255) NULL,
	[DBRole] [nvarchar](255) NULL,
	[Zugriff] [nvarchar](255) NULL,
	[Berechtgung] [nvarchar](255) NULL,
	[Objecktyp] [nvarchar](255) NULL,
	[Schema] [nvarchar](255) NULL,
	[Objecktname] [nvarchar](255) NULL,
	[Spalte] [nvarchar](255) NULL,
 CONSTRAINT [unq_WhiteList] UNIQUE NONCLUSTERED 
(
	[User] ASC,
	[DBRole] ASC,
	[Zugriff] ASC,
	[Berechtgung] ASC,
	[Schema] ASC,
	[Objecktname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


