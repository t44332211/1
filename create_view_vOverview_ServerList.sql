USE [IB15_DBVerwaltung_ps59_1]
GO


CREATE   VIEW [elasticauditreport].[vOverview_ServerList] WITH SCHEMABINDING AS
	select  ins.IDSQLServerInstance,
			ins.IDSQLServer,
			ins.strInstanceName,
			ins.strPhysicalServername,
			ins.intPort,
			ins.bCheck,
			ins.bCheckRights,
			ins.strInstanceName  AS connectionname 
    FROM [elasticaudit].[T_SQLServerInstances] ins

GO


