/*
This script runs before restores to set the database to single user mode, and then kill active connections to allow the restore to complete
*/

DECLARE @db VARCHAR(100) = 'BIAnalytics_Test'
DECLARE @dbid int = (SELECT database_id FROM master.sys.databases WHERE name = @db)
DECLARE @sql NVARCHAR(MAX)

--SET SINGLE USER
SET @sql = ''
SET @sql = N'ALTER DATABASE [' + @db + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; ' + NCHAR(13);
BEGIN
	--PRINT @sql
	EXEC master.sys.sp_executesql @stmt = @sql;
END

--KILL CONNECTIONS
SET @sql = ''
SELECT @sql = @sql + N'KILL ' + CAST(spid as nvarchar(5)) + N';' + NCHAR(13)
--SELECT *
FROM sys.sysprocesses s
WHERE s.dbid = @dbid
IF @sql IS NULL OR @sql = ''
BEGIN
	PRINT '@sql is NULL for kill spid'
END
ELSE
BEGIN
	--PRINT @sql
	EXEC master.sys.sp_executesql @stmt = @sql;
END

--backup
--restore
--put db back into MULTI_USER mode
--ALTER DATABASE BIAnalytics_Test SET MULTI_USER