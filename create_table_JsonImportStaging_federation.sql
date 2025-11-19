USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [MONGODB].[JsonImportStaging_federation](
	[snapshot_timestamp] [smalldatetime] NULL,
	[RawJson] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


