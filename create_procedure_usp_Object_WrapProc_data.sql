USE [IB15_DBVerwaltung_ps59_1]
GO
/****** Object:  StoredProcedure [mssqlauditreport].[usp_Object_WrapProc_data]    Script Date: 23.07.2025 15:12:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [MONGODBauditreport].[usp_Object_WrapProc_data]
	@serverName NVARCHAR(max) = NULL,  --for multiple values
	@dbName		NVARCHAR(max) = NULL,  --for multiple values
	@snapshot	NVARCHAR(max) = NULL,  --for multiple values
    @personrole NVARCHAR(max) = NULL,  --for multiple values
	@latecert   NVARCHAR(max) = NULL,  --for multiple values
	@whitelist	BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Parameters  [MONGODBauditreport].[TT_InputParameters] 
	INSERT INTO  @Parameters
	exec [MONGODBauditreport].[usp_DatenbankenByUser_para] @serverName, @dbName, @snapshot, @personrole, @latecert, @whitelist

	exec [MONGODBauditreport].[usp_objectperm_data] @Parameters=@Parameters

END