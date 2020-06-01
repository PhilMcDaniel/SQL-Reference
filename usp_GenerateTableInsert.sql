ALTER PROCEDURE usp_GenerateTableInsert
	@tbl NVARCHAR(100) = ''
	,@sch NVARCHAR(100) = ''
AS
BEGIN

	SET NOCOUNT ON;

--table for insert
IF OBJECT_ID('tempdb..#tbl','U') IS NOT NULL BEGIN DROP TABLE #tbl END
SELECT DB_NAME() db,s.name sch,t.name tbl,c.is_identity
INTO #tbl
FROM sys.tables t
INNER JOIN sys.schemas s
	ON t.schema_id = s.schema_id
LEFT OUTER JOIN sys.columns c
	ON t.object_id = c.object_id
	AND c.is_identity = 1
WHERE t.name = @tbl
AND s.name = @sch

--indentity insert on
DECLARE @idonssql NVARCHAR(MAX) = (SELECT CASE WHEN is_identity = 1 THEN CONCAT(' SET IDENTITY_INSERT [',db,'_TEST].[',sch,'].[',tbl,'] ON ') ELSE ' ' END FROM #tbl)
DECLARE @idoffssql NVARCHAR(MAX) = (SELECT CASE WHEN is_identity = 1 THEN CONCAT(' SET IDENTITY_INSERT [',db,'_TEST].[',sch,'].[',tbl,'] OFF ') ELSE ' ' END FROM #tbl)
--SELECT @idonssql

--INSERT sql
DECLARE @insertsql NVARCHAR(MAX) = (SELECT CONCAT('INSERT INTO [',db,'_TEST].[',sch,'].[',tbl,'] ') FROM #tbl)
--SELECT @insertsql

--column list
IF OBJECT_ID('tempdb..#collist','U') IS NOT NULL BEGIN DROP TABLE #collist END
SELECT DB_NAME() db,s.name sch,t.name tbl,c.name col,c.column_id,ROW_NUMBER() OVER (ORDER BY column_id) rownum
INTO #collist
FROM sys.tables t
INNER JOIN sys.schemas s
	ON t.schema_id = s.schema_id
INNER JOIN sys.columns c
	ON t.object_id = c.object_id
WHERE t.name = @tbl
AND s.name = @sch
--SELECT * FROM #collist

DECLARE @colsql NVARCHAR(MAX) = ''
DECLARE @i int = (SELECT MIN(rownum) FROM #collist)

--loop to build col insert list sql
WHILE @i <= (SELECT MAX(rownum) FROM #collist)
BEGIN
	SET @colsql =	CONCAT(@colsql,	(SELECT CASE
												WHEN @i = (SELECT MIN(rownum) FROM #collist) THEN ''
												ELSE ','
											END)
					,(SELECT col FROM #collist WHERE rownum = @i))
	--PRINT @i
	--PRINT @colsql
	SET @i = @i+1
END

DECLARE @finalsql NVARCHAR(MAX) = (SELECT CONCAT(@idonssql,@insertsql,'(',@colsql,') ','SELECT ',@colsql,' FROM [',db,'].[',sch,'].[',tbl,']',@idoffssql) FROM #tbl)
SELECT @finalsql

END