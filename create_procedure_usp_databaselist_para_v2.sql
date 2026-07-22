USE [IB15_DBVerwaltung_ps733]
GO

/****** Object:  StoredProcedure [postgresauditreport].[usp_databaselist_para]    Script Date: 21.07.2026 13:54:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [postgresauditreport].[usp_databaselist_para_v2]
	--@serverName  NVARCHAR(max)  = NULL --for multiple values
	--,@personrole NVARCHAR(max)  = NULL --for multiple values
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @admin BIT = 0;
	EXECUTE AS CALLER;
	SELECT @admin = IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL')
	REVERT;

	SELECT DISTINCT  --tab1.IDSQLDatabase
					tab1.datname AS databasename
	FROM [postgresaudit].[T_Databases] tab1 --(@serverName) tab1
	WHERE (--@admin=1 --admin
		1=1
		--OR
		--(  
		--	(tab1.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	 OR tab1.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	 OR tab1.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	 OR tab1.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	 OR	tab1.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	 OR	tab1.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	 OR	tab1.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
		--	)
	 -- )
	 )
	 ORDER BY 1

END


GO


