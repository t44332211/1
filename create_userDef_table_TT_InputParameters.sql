USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE TYPE [elasticauditreport].[TT_InputParameters] AS TABLE(
	[id] [int] NULL,
	[timestamp] [smalldatetime] NULL,
	[IDSQLDatabase] [int] NULL,
	[Datenbankname] [varchar](150) NULL,
	[strInstanceName] [varchar](150) NULL,
	[strSQLServerName] [varchar](150) NULL,
	[strFullInstanceName] [varchar](150) NULL,
	[DataEnabler1] [varchar](150) NULL,
	[DataEnabler2] [varchar](150) NULL,
	[DataEnabler3] [varchar](150) NULL,
	[DataOwner] [varchar](150) NULL,
	[DataSteward1] [varchar](150) NULL,
	[DataSteward2] [varchar](150) NULL,
	[DataSteward3] [varchar](150) NULL,
	[PersonRole] [varchar](2000) NULL,
	[idtimestampprev] [int] NULL,
	[timestamp_prev] [smalldatetime] NULL,
	[whitelist] [bit] NULL,
	principal_id bigint
)
GO


