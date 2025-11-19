USE [IB15_DBVerwaltung_ps59_2]
GO

CREATE OR ALTER PROCEDURE [elastic].[LoadJsonFiles]
AS
BEGIN
--!!!!!! If necessary
--EXEC sp_configure 'show advanced options', 1;
--RECONFIGURE;
--EXEC sp_configure 'xp_cmdshell', 1;
--RECONFIGURE;

DROP TABLE IF EXISTS #FileList;
CREATE TABLE #FileList(
	FileName NVARCHAR(255)
);


 DECLARE @FolderPath NVARCHAR(255);
 SET @FolderPath  = '\\lan.huk-coburg.de\Prj-REZUDB\TEAM\Arbeitsbereich_ps733\ELASTICAUDIT_Scripts\Json filee\';
  -- SET @FolderPath = 'O:\Prj-REZUDB\TEAM\Arbeitsbereich_ps733\ELASTICAUDIT_Scripts\Json filee\';

DECLARE @cmd NVARCHAR(4000);
SET @cmd = 'dir "' + @FolderPath + '" /b /s';

INSERT INTO #FileList (FileName)
EXEC xp_cmdshell @cmd;

DECLARE @CurrentFileName NVARCHAR(255);
DECLARE @Sql NVARCHAR(MAX);
DECLARE @CreateDateTime NVARCHAR(50);

DROP TABLE IF EXISTS #DirOutput;
CREATE TABLE #DirOutput (
	Line VARCHAR(4000)
);

DECLARE FileCursor CURSOR FOR
SELECT FileName FROM #FileList WHERE FileName IS NOT NULL;

OPEN FileCursor;

FETCH NEXT FROM FileCursor INTO @CurrentFileName;

WHILE @@FETCH_STATUS = 0
BEGIN

	DELETE FROM #DirOutput;
	
	SET @Cmd = 'for %i in ("' + @CurrentFileName + '") do @echo %~ti %i';

	INSERT INTO #DirOutput
	EXEC xp_cmdshell @Cmd;

	SET @CreateDateTime = (SELECT TOP 1 LEFT(Line,17)
	FROM #DirOutput WHERE Line is not null);

	SET @Sql = 'INSERT INTO [elasticaudit].[JsonImportStaging] (snapshot_timestamp,RawJson)
	SELECT CONVERT(DATETIME, ''' + @CreateDateTime + ''', 120), BulkColumn
	FROM OPENROWSET (
		BULK ''' + @CurrentFileName + ''',
		SINGLE_CLOB
	) AS j;';

	EXEC sp_executesql @Sql;

	--write log import
	INSERT INTO [elastic].[JsonImportLog] VALUES (@CurrentFileName,@CreateDateTime,GETDATE());

	FETCH NEXT FROM FileCursor INTO @CurrentFileName;
END

--EXEC sp_configure 'show advanced options', 0;
--RECONFIGURE;
--EXEC sp_configure 'xp_cmdshell', 0;
--RECONFIGURE;

END
GO


