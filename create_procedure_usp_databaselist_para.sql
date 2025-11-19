USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER PROCEDURE [elasticauditreport].[usp_databaselist_para]
	@serverName  NVARCHAR(max)  = NULL --for multiple values
	--,@personrole NVARCHAR(max)  = NULL --for multiple values
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @admin BIT = 0;
	EXECUTE AS CALLER;
	SELECT @admin = IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL')
	--SELECT @admin = IS_MEMBER('LAN\GgpAcc-SSISAcc-IB15Verwaltung')
	REVERT;

	SELECT DISTINCT  tab1.IDSQLDatabase
					,tab1.Datenbankname AS databasename
	FROM [elasticauditreport].[get_OverviewDatabases_online] (@serverName) tab1
	WHERE (@admin=1 --admin
		OR
		(  
			(tab1.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR tab1.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR tab1.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR tab1.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR	tab1.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR	tab1.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			 OR	tab1.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
			)
	  )
	 )
	ORDER BY 2;

END


