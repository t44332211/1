USE [IB15_DBVerwaltung_ps733]
GO

/****** Object:  StoredProcedure [postgresauditreport].[usp_Global_WrapProc_data]    Script Date: 21.07.2026 14:05:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [postgresauditreport].[usp_Global_WrapProc_data_v2]
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
	DECLARE	@serverName NVARCHAR(max) = NULL  --for multiple values
	DECLARE @Parameters  [postgresauditreport].[TT_InputParameters] 
	INSERT INTO  @Parameters
	exec [postgresauditreport].[usp_DatenbankenByUser_para_v2] @dbName, @snapshot, @personrole, @latecert, @whitelist

	exec [postgresauditreport].[usp_globalperm_data_v2] @Parameters=@Parameters

END
GO


