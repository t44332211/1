USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE   VIEW [MONGODBauditreport].[vOverview_WhiteList]  WITH SCHEMABINDING AS
SELECT [User]
      ,[DBRole]
      ,[Zugriff]
      ,[Berechtgung]
      ,[Objecktyp]
      ,[Schema]
      ,[Objecktname]
      ,[Spalte]
  FROM [mssqlaudit].[WhiteList]
GO


