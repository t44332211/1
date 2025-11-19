USE [IB15_DBVerwaltung_ps59_1]
GO

CREATE OR ALTER VIEW [elasticauditreport].[vOverview_WhiteList]  WITH SCHEMABINDING AS
SELECT [User]
      ,[DBRole]
      ,[Zugriff]
      ,[Berechtgung]
      ,[Objecktyp]
      ,[Schema]
      ,[Objecktname]
      ,[Spalte]
  FROM [elasticaudit].[WhiteList]
  GO