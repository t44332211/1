USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER PROCEDURE [MONGODBauditreport].[usp_latecertlist_para] 
	-- Add the parameters for the stored procedure here
	 @serverName NVARCHAR(max) = NULL  --for multiple values
	,@dbName		NVARCHAR(max) = NULL  --for multiple values
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
	--SELECT @admin = IS_MEMBER('LAN\GgpAcc-SSISAcc-IB15Verwaltung');
	REVERT;

	SELECT DISTINCT CONVERT(NVARCHAR(20), cts.dtSnapshot,120) + SPACE(30 - LEN(CONVERT(NVARCHAR(20), cts.dtSnapshot,120))) AS [timestamp]
	FROM [MONGODBaudit].[T_DBCertTimestamps] AS cts
	JOIN [MONGODBauditreport].get_OverviewDatabases_online(@serverName) AS dbs
		ON cts.idDB = dbs.IDSQLDatabase
			AND (trim(@dbName) IS NULL OR dbs.Datenbankname IN (select trim(value) value from string_split(@dbName,',') where trim(value) is not null))
			AND (@admin=1 --admin
			OR
			(  
				(dbs.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR dbs.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR dbs.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR dbs.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR	dbs.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR	dbs.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				 OR	dbs.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
				)
			 )
			)
	WHERE cts.dtSnapshot < CONVERT(SMALLDATETIME, @snapshot, 102)
	UNION ALL
	SELECT NULL timestamp
	ORDER BY [timestamp] DESC
END
