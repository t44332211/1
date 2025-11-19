USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER PROCEDURE [MONGODBauditreport].[usp_snapshotlist_para] 
	-- Add the parameters for the stored procedure here
	 @serverName NVARCHAR(max) = NULL --for multiple values
	,@dbName		NVARCHAR(max) = NULL --for multiple values
	--,@personrole NVARCHAR(max) = NULL  --for multiple values
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
	
    -- Insert statements for procedure here
	SELECT DISTINCT CONVERT(NVARCHAR(20),ob.dtSnapshot,120) + space(30 - len(CONVERT(NVARCHAR(20),ob.dtSnapshot,120)))	 AS snapshot_timestamp
	FROM  [MONGODBauditreport].[get_OverviewDBPermissions] (@serverName, @dbName) ob
	WHERE (@admin=1 --admin
						OR
						(  
							(ob.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							 OR ob.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							 OR ob.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							 OR ob.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							 OR	ob.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							 OR	ob.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							 OR	ob.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
							)
						 )
						)
	ORDER BY 1
END
