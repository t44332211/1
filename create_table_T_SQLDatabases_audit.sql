USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE TABLE [MONGODBaudit].[T_SQLDatabases](
	[IDSQLDatabase] [bigint] NOT NULL,
	[dbid] [nvarchar](255) NULL,
	[IDSQLServerInstance] [int] NOT NULL,
	[dtSnapshot] [smalldatetime] NOT NULL,
	[strDatabaseName] [varchar](100) NOT NULL,
	[intDatabaseID] [int] NULL,
	[intDBSize]  AS (isnull([dataSizeMB],(0))+isnull([logSizeMB],(0))),
	[dtLastAccessed] [datetime] NULL,
	[dtCreateDate] [datetime] NOT NULL,
	[tableCount] [int] NULL,
	[indexCount] [int] NULL,
	[dataSizeMB] [int] NULL,
	[countDataFiles] [tinyint] NOT NULL,
	[logSizeMB] [int] NULL,
	[countLogFiles] [tinyint] NOT NULL,
	[logUsage] [float] NOT NULL,
	[logUsageMax] [float] NOT NULL,
	[reservedPageCount] [bigint] NULL,
	[indexPageCount] [bigint] NULL,
	[dataPageCount] [bigint] NULL,
	[unusedPageCount] [bigint] NULL,
	[Owner] [varchar](12) NULL,
	[Substitute1] [varchar](12) NULL,
	[Substitute2] [varchar](12) NOT NULL,
	[DataOwner] [varchar](12) NULL,
	[DataSteward1] [varchar](12) NULL,
	[DataSteward2] [varchar](12) NULL,
	[DataSteward3] [varchar](12) NULL,
	[PLK] [varchar](20) NULL,
	[bPLKSys] [bit] NOT NULL,
	[Application] [varchar](50) NULL,
	[SLF] [varchar](3) NOT NULL,
	[bSLFSys] [bit] NOT NULL,
	[SLA] [varchar](6) NOT NULL,
	[7x24] [bit] NOT NULL,
	[WAF] [tinyint] NOT NULL,
	[WAFPrio] [varchar](3) NOT NULL,
	[SBK] [tinyint] NOT NULL,
	[ClientAccess] [bit] NOT NULL,
	[DeveloperAccess] [bit] NOT NULL,
	[ackBackupPolicy] [bit] NOT NULL,
	[ackBackupPolicyDate] [smalldatetime] NULL,
	[ackBackupPolicyUser] [varchar](12) NULL,
	[isOnline] [bit] NULL,
	[source_database_id] [int] NULL,
	[owner_sid] [varbinary](85) NULL,
	[create_date] [datetime] NULL,
	[compatibility_level] [tinyint] NULL,
	[collation_name] [nvarchar](128) NULL,
	[user_access] [tinyint] NULL,
	[user_access_desc] [nvarchar](60) NULL,
	[is_read_only] [bit] NULL,
	[is_auto_close_on] [bit] NULL,
	[is_auto_shrink_on] [bit] NULL,
	[state] [tinyint] NULL,
	[state_desc] [nvarchar](60) NULL,
	[is_in_standby] [bit] NULL,
	[is_cleanly_shutdown] [bit] NULL,
	[is_supplemental_logging_enabled] [bit] NULL,
	[snapshot_isolation_state] [tinyint] NULL,
	[snapshot_isolation_state_desc] [nvarchar](60) NULL,
	[is_read_committed_snapshot_on] [bit] NULL,
	[recovery_model] [tinyint] NULL,
	[recovery_model_desc] [nvarchar](60) NULL,
	[page_verify_option] [tinyint] NULL,
	[page_verify_option_desc] [nvarchar](60) NULL,
	[is_auto_create_stats_on] [bit] NULL,
	[is_auto_create_stats_incremental_on] [bit] NULL,
	[is_auto_update_stats_on] [bit] NULL,
	[is_auto_update_stats_async_on] [bit] NULL,
	[is_ansi_null_default_on] [bit] NULL,
	[is_ansi_nulls_on] [bit] NULL,
	[is_ansi_padding_on] [bit] NULL,
	[is_ansi_warnings_on] [bit] NULL,
	[is_arithabort_on] [bit] NULL,
	[is_concat_null_yields_null_on] [bit] NULL,
	[is_numeric_roundabort_on] [bit] NULL,
	[is_quoted_identifier_on] [bit] NULL,
	[is_recursive_triggers_on] [bit] NULL,
	[is_cursor_close_on_commit_on] [bit] NULL,
	[is_local_cursor_default] [bit] NULL,
	[is_fulltext_enabled] [bit] NULL,
	[is_trustworthy_on] [bit] NULL,
	[is_db_chaining_on] [bit] NULL,
	[is_parameterization_forced] [bit] NULL,
	[is_master_key_encrypted_by_server] [bit] NULL,
	[is_query_store_on] [bit] NULL,
	[is_published] [bit] NULL,
	[is_subscribed] [bit] NULL,
	[is_merge_published] [bit] NULL,
	[is_distributor] [bit] NULL,
	[is_sync_with_backup] [bit] NULL,
	[service_broker_guid] [uniqueidentifier] NULL,
	[is_broker_enabled] [bit] NULL,
	[log_reuse_wait] [tinyint] NULL,
	[log_reuse_wait_desc] [nvarchar](60) NULL,
	[is_date_correlation_on] [bit] NULL,
	[is_cdc_enabled] [bit] NULL,
	[is_encrypted] [bit] NULL,
	[is_honor_broker_priority_on] [bit] NULL,
	[replica_id] [uniqueidentifier] NULL,
	[group_database_id] [uniqueidentifier] NULL,
	[resource_pool_id] [int] NULL,
	[default_language_lcid] [smallint] NULL,
	[default_language_name] [nvarchar](128) NULL,
	[default_fulltext_language_lcid] [int] NULL,
	[default_fulltext_language_name] [nvarchar](128) NULL,
	[is_nested_triggers_on] [bit] NULL,
	[is_transform_noise_words_on] [bit] NULL,
	[two_digit_year_cutoff] [smallint] NULL,
	[containment] [tinyint] NULL,
	[containment_desc] [nvarchar](60) NULL,
	[target_recovery_time_in_seconds] [int] NULL,
	[delayed_durability] [int] NULL,
	[delayed_durability_desc] [nvarchar](60) NULL,
	[is_memory_optimized_elevate_to_snapshot_on] [bit] NULL,
	[is_federation_member] [bit] NULL,
	[is_remote_data_archive_enabled] [bit] NULL,
	[is_mixed_page_allocation_on] [bit] NULL,
	[is_temporal_history_retention_enabled] [bit] NULL,
	[catalog_collation_type] [int] NULL,
	[catalog_collation_type_desc] [nvarchar](60) NULL,
	[physical_database_name] [nvarchar](128) NULL,
	[is_result_set_caching_on] [bit] NULL,
	[is_accelerated_database_recovery_on] [bit] NULL,
	[is_tempdb_spill_to_remote_store] [bit] NULL,
	[is_stale_page_detection_on] [bit] NULL,
	[is_memory_optimized_enabled] [bit] NULL,
 CONSTRAINT [pk_T_SQLDatabases] PRIMARY KEY CLUSTERED 
(
	[dtSnapshot] ASC,
	[IDSQLServerInstance] ASC,
	[IDSQLDatabase] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UNQ_T_SQLDatabases] UNIQUE NONCLUSTERED 
(
	[dtSnapshot] ASC,
	[IDSQLServerInstance] ASC,
	[dbid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_dtCreateDate]  DEFAULT (getdate()) FOR [dtCreateDate]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_countDataFiles]  DEFAULT ((1)) FOR [countDataFiles]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_countLogFiles]  DEFAULT ((1)) FOR [countLogFiles]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_logUsage]  DEFAULT ((0)) FOR [logUsage]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_logUsageMax]  DEFAULT ((0)) FOR [logUsageMax]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_Substitute2]  DEFAULT ('') FOR [Substitute2]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_bPLKSys]  DEFAULT ((0)) FOR [bPLKSys]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_Application]  DEFAULT ('Microsoft SQL Server') FOR [Application]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_SLF]  DEFAULT ((3.2)) FOR [SLF]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_bSLFSys]  DEFAULT ((0)) FOR [bSLFSys]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_SLA]  DEFAULT ('Bronze') FOR [SLA]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_7x24]  DEFAULT ((0)) FOR [7x24]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_WAF]  DEFAULT ((2)) FOR [WAF]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_WAFPrio]  DEFAULT ((2)) FOR [WAFPrio]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_SBK]  DEFAULT ((2)) FOR [SBK]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_ClientAccess]  DEFAULT ((0)) FOR [ClientAccess]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_DeveloperAccess]  DEFAULT ((0)) FOR [DeveloperAccess]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] ADD  CONSTRAINT [DF_T_SQLDatabases_ackBackupPolicy]  DEFAULT ((0)) FOR [ackBackupPolicy]
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases]  WITH CHECK ADD  CONSTRAINT [FK_T_SQLDatabases_IDSQLDatabase] FOREIGN KEY([IDSQLDatabase])
REFERENCES [MONGODB].[T_SQLDatabases] ([IDSQLDatabase])
GO

ALTER TABLE [MONGODBaudit].[T_SQLDatabases] CHECK CONSTRAINT [FK_T_SQLDatabases_IDSQLDatabase]
GO


