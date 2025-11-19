USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [elasticaudit].[T_SQLServerInstances](
	[IDSQLServerInstance] [int] NOT NULL,
	[IDSQLServer] [int] NULL,
	[strInstanceName] [varchar](50) NOT NULL,
	[strDescription] [varchar](250) NULL,
	[intPort] [smallint] NULL,
	[strPhysicalServername] [varchar](50) NULL,
	[strServiceAccount] [varchar](50) NULL,
	[intCores] [tinyint] NULL,
	[bHT] [bit] NULL,
	[bFachtest] [bit] NULL,
	[bLic] [bit] NULL,
	[bPatch] [bit] NULL,
	[intRAM] [int] NULL,
	[intRAMInstMin] [int] NULL,
	[intRAMInstMax] [int] NULL,
	[strEdition] [varchar](120) NULL,
	[strLanguage] [varchar](50) NULL,
	[strBuild] [varchar](20) NULL,
	[strServicePack] [varchar](5) NULL,
	[dtLastUpdate] [datetime] NULL,
	[bSAN] [bit] NULL,
	[bSANgespiegelt] [bit] NULL,
	[bCheck] [bit] NULL,
	[bCheckLockedUsers] [bit] NULL,
	[bCheckUserOwners] [bit] NULL,
	[bCheckExpiringPasswords] [bit] NULL,
	[bLockUsers] [bit] NULL,
	[bCheckDBs] [bit] NULL,
	[bCheckSPN] [bit] NULL,
	[bCheckFrag] [bit] NULL,
	[bCheckRights] [bit] NULL,
	[bSetDefaultDBOwner] [bit] NULL,
	[bBUallowed] [bit] NULL,
	[bSSL] [bit] NULL,
	[bSQLAuth] [bit] NULL,
	[strSQLServerInstanceVersion] [varchar](250) NULL,
	[strSQLLogin] [varchar](200) NULL,
	[strSQLLoginPassword] [varchar](200) NULL,
	[dtLastAccessed] [smalldatetime] NULL,
	[dtCreateDate] [smalldatetime] NULL,
 CONSTRAINT [PK_T_SQLServerInstances] PRIMARY KEY CLUSTERED 
(
	[IDSQLServerInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [elasticaudit].[T_SQLServerInstances] ADD  CONSTRAINT [DF_T_SQLServerInstances_ID]  DEFAULT (NEXT VALUE FOR [ELASTICaudit].[HSequence_ID_SQLServerInstances]) FOR [IDSQLServerInstance]
GO


