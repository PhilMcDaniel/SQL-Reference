--space on drives before
--dbcc shrinkdatabase for ??database
--space on drives after

SET NOCOUNT ON;
EXEC BIAnalytics.AuditDatabase.InsertStoredProcedurePerformanceTimestamp 'Database shrinking',  'Start database shrinking'

--list of databases in temp table
IF OBJECT_ID('tempdb..#dbs','U') IS NOT NULL BEGIN DROP TABLE #dbs END
SELECT name,database_id
INTO #dbs
FROM msdb.sys.databases
WHERE name NOT IN ('master','tempdb','model','msdb','DBMAINT')
--SELECT * FROM #dbs


--drive space before
IF OBJECT_ID('tempdb..#drivesbefore','U') IS NOT NULL BEGIN DROP TABLE #drivesbefore END
SELECT DISTINCT
volume_mount_point
,total_bytes/(POWER(1024,3)) total_GB
,available_bytes/(POWER(1024,3)) available_gb
INTO #drivesbefore
FROM master.sys.master_files AS f  CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
SELECT * FROM #drivesbefore


--temp table to store final results
IF OBJECT_ID('tempdb..#final','U') IS NOT NULL BEGIN DROP TABLE #final END
CREATE TABLE #final
(
database_id int NOT NULL
,database_nme varchar(200) NOT NULL
,SQLStatement NVARCHAR(MAX) NOT NULL
)

--loop through databases to build SQL statements for each DB
DECLARE @i int
DECLARE @sql1 NVARCHAR(MAX) = ''

SET @i = (SELECT MIN(database_id) FROM #dbs)

WHILE @i <= (SELECT MAX(database_id) FROM #dbs)
BEGIN
	SET @sql1 = ''
	
	
	SET @sql1 = 'DBCC SHRINKDATABASE('''+(SELECT name FROM #dbs WHERE database_id = @i)+''',10) '
	
	INSERT INTO #final (database_id,database_nme,SQLStatement)
	SELECT database_id,name,@sql1 FROM #dbs WHERE database_id = @i
	
	
	EXEC BIAnalytics.AuditDatabase.InsertStoredProcedurePerformanceTimestamp 'Database shrinking',  @sql1
	PRINT @sql1
	--EXEC sp_executesql @statement = @sql1

	SET @i = @i + 1
END


--drive space after
IF OBJECT_ID('tempdb..#drivesafter','U') IS NOT NULL BEGIN DROP TABLE #drivesafter END
SELECT DISTINCT
volume_mount_point
,total_bytes/(POWER(1024,3)) total_GB
,available_bytes/(POWER(1024,3)) available_gb
INTO #drivesafter
FROM master.sys.master_files AS f  CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
SELECT * FROM #drivesafter

EXEC BIAnalytics.AuditDatabase.InsertStoredProcedurePerformanceTimestamp 'Database shrinking',  'End database shrinking'