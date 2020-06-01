/*
This script shrinks all log files for ONLINE databases". Meant to be used before restoring to free up space
*/
SET NOCOUNT ON;
DECLARE @sql NVARCHAR(MAX) = ''
DECLARE @i int

--list of databases
IF OBJECT_ID('tempdb..#dbs') IS NOT NULL BEGIN DROP TABLE #dbs END
SELECT
CONCAT('[',name,']') db
,database_id
,ROW_NUMBER() OVER (ORDER BY database_id) rownum
INTO #dbs
FROM master.sys.databases
WHERE state_desc = 'ONLINE'
--SELECT * FROM #dbs

--loop through to create and execute DBCC SHRINKFILE statement on the chosen file in the chosen db
SET @i = (SELECT MIN(rownum) FROM #dbs)
SET @sql = ''
WHILE @i <= (SELECT MAX(rownum) FROM #dbs)
BEGIN
	SET @sql = CONCAT('USE ',(SELECT db FROM #dbs WHERE rownum = @i)
	,CHAR(13)
	,'DBCC SHRINKFILE(''',(SELECT name FROM sys.master_files m WHERE m.type_desc = 'Log' AND database_id = (SELECT database_id FROM #dbs WHERE rownum = @i)),''')')
	IF @sql IS NULL OR @sql = ''
	BEGIN
		PRINT ('whoops')
	END
	ELSE
	BEGIN
		EXEC sp_executesql @statement = @sql
	END
	--PRINT @sql
	SET @i = @i+1
END