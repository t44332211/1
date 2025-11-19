USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER PROCEDURE [elasticauditreport].[usp_Object_WrapProc_data]
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
	DECLARE @Parameters  [elasticauditreport].[TT_InputParameters] 
	INSERT INTO  @Parameters
	exec [elasticauditreport].[usp_DatenbankenByUser_para] @serverName, @dbName, @snapshot, @personrole, @latecert, @whitelist

	exec [elasticauditreport].[usp_objectperm_data] @Parameters=@Parameters

END