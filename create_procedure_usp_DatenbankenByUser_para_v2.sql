USE [IB15_DBVerwaltung_ps733]
GO

/****** Object:  StoredProcedure [postgresauditreport].[usp_DatenbankenByUser_para]    Script Date: 21.07.2026 13:55:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [postgresauditreport].[usp_DatenbankenByUser_para_v2]
	@dbName		NVARCHAR(max) = NULL,  --for multiple values
	@snapshot	NVARCHAR(max) = NULL,  --for multiple values
    @personrole NVARCHAR(max) = NULL,   --for multiple values
	@latecert   NVARCHAR(max) = NULL,	--for multiple values
	@whitelist  BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @admin BIT = 0;
	DECLARE @serverName NVARCHAR(max) = 'UNKNOWN' 


	EXECUTE AS CALLER;
	SELECT @admin = IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL') 
	--SELECT @admin = IS_MEMBER('LAN\GgpAcc-SSISAcc-IB15Verwaltung');
	REVERT;

	SELECT DISTINCT
		 null							AS [id]	
		,DBO.dtSnapshot				    AS [timestamp]
		,DBO.oid						AS [IDSQLDatabase]
		,DBO.datname					AS [Datenbankname]
		,null							AS [strInstanceName]
		,null							AS [strSQLServerName]
		,null							AS [strFullInstanceName]
		,null							AS DataEnabler1
		,null							AS DataEnabler2
		,null							AS DataEnabler3
		,null							AS [DataOwner]
		,null							AS [DataSteward1]
		,null							AS [DataSteward2]
		,null							AS [DataSteward3]
		,trim(@personrole)				AS [PersonRole]	
		,ssh_prev.id					AS [idtimestampprev]
		,ssh_prev.timestamp				AS [timestamp_prev]
		,@whitelist						AS whitelist
		,null							AS principal_id
		,SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1) AS LoginName
	FROM  [postgresaudit].[T_Databases] DBO
	OUTER APPLY (SELECT TOP(1)  null id, ssh_prev.dtSnapshot timestamp 
				 --select onlycertificated snapshot
				 FROM  [mssqlaudit].[T_DBCertTimestamps] ssh_prev 
				 WHERE  ssh_prev.dtSnapshot < DBO.dtSnapshot
				   AND convert(smalldatetime,@latecert,102) = (select convert(smalldatetime,value,102) from string_split(@latecert,',') where value is not null)
				 ORDER BY ssh_prev.dtSnapshot DESC) ssh_prev

	WHERE  DBO.datname=@dbName
	  AND (@snapshot IS NULL 
				OR convert(smalldatetime,DBO.dtSnapshot,102) IN (select convert(smalldatetime,value,102) from string_split(@snapshot,',') where value is not null)
			)
			AND (--@admin=1 --admin
				1=1
				/*OR
				(  
					(DBO.[Owner] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					 OR DBO.[Substitute1] =SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					 OR DBO.[Substitute2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					 OR DBO.[DataOwner] =  SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					 OR	DBO.[DataSteward1] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					 OR	DBO.[DataSteward2] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					 OR	DBO.[DataSteward3] = SUBSTRING(ORIGINAL_LOGIN(), CHARINDEX('\', ORIGINAL_LOGIN(), 0) + 1, LEN(ORIGINAL_LOGIN()) - CHARINDEX(ORIGINAL_LOGIN(), '\', 0) - 1)
					)
			)*/
		  )
	
END
GO


