USE [IB15_DBVerwaltung_ps733]
GO

/****** Object:  StoredProcedure [postgresauditreport].[usp_snapshotlist_para]    Script Date: 21.07.2026 13:59:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [postgresauditreport].[usp_snapshotlist_para_v2] 
	-- Add the parameters for the stored procedure here
	 --@serverName NVARCHAR(max) = NULL --for multiple values
	@dbName		NVARCHAR(max) = NULL --for multiple values
	--,@personrole NVARCHAR(max) = NULL  --for multiple values
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @admin BIT = 0;
	EXECUTE AS CALLER;
	SELECT @admin = IS_MEMBER('LAN\GgpAdf-ApplDatenbankserver-MSSQL')
	REVERT;
	
    -- Insert statements for procedure here
	SELECT DISTINCT CONVERT(NVARCHAR(20),ob.dtSnapshot,120) + space(30 - len(CONVERT(NVARCHAR(20),ob.dtSnapshot,120)))	 AS snapshot_timestamp
	FROM  [postgresaudit].[T_Databases]  ob
	WHERE ob.datname = @dbName
	and  (1=1 --@admin=1 --admin
		
		)
	ORDER BY 1
END
GO


