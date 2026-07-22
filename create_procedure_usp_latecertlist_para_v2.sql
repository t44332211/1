USE [IB15_DBVerwaltung_ps733]
GO

/****** Object:  StoredProcedure [postgresauditreport].[usp_latecertlist_para]    Script Date: 21.07.2026 13:57:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [postgresauditreport].[usp_latecertlist_para_v2] 
	-- Add the parameters for the stored procedure here
	 --@serverName NVARCHAR(max) = NULL  --for multiple values
	@dbName		NVARCHAR(max) = NULL  --for multiple values
	,@snapshot	NVARCHAR(max) = NULL  --for multiple values
    --,@personrole NVARCHAR(max) = NULL   --for multiple values
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @admin BIT = 0;
	EXECUTE AS CALLER;
	SELECT @admin = IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL') 
	REVERT;

	SELECT DISTINCT CONVERT(NVARCHAR(20), cts.dtSnapshot,120) + SPACE(30 - LEN(CONVERT(NVARCHAR(20), cts.dtSnapshot,120))) AS [timestamp]
	FROM [postgresaudit].[T_DBCertTimestamps] AS cts
	JOIN [postgresaudit].[T_Databases] dbs
		ON cts.datname = dbs.datname
			AND (trim(@dbName) IS NULL OR dbs.datname IN (select trim(value) value from string_split(@dbName,',') where trim(value) is not null))
			AND (1=1 --@admin=1 --admin
			)
	WHERE cts.dtSnapshot < CONVERT(SMALLDATETIME, @snapshot, 102)
	UNION ALL
	SELECT NULL timestamp
	ORDER BY [timestamp] DESC
END
GO


