
BEGIN
	SET NOCOUNT ON;

--check for valid @type param
IF @type NOT IN ('DISABLE','REBUILD')
BEGIN
	RAISERROR ('Please enter a value of REBUILD or DISABLE for @type', -- Message text.
               16, -- Severity.
               1 -- State.
               )
END

--check for valid @sch param
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @sch)
BEGIN
	RAISERROR ('Please enter a valid schema name for @sch', -- Message text.
               16, -- Severity.
               1 -- State.
               )
END

--check for valid @tbl param
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = @tbl)
BEGIN
	RAISERROR ('Please enter a valid table name for @tbl', -- Message text.
               16, -- Severity.
               1 -- State.
               )
END


--put list of indexes into #list along with statement to disable
--pass in schema and table name
IF OBJECT_ID('tempdb..#list','U') IS NOT NULL BEGIN DROP TABLE #list END
SELECT
i.name idx
,SCHEMA_NAME(t.schema_id) schm
,t.name tbl
,N'	IF EXISTS	(
				SELECT 1
				FROM sys.indexes i 
				INNER JOIN sys.objects o 
					ON i.object_id = o.object_id
				INNER JOIN sys.schemas s
					ON o.schema_id = s.schema_id
				WHERE i.name = '''+i.name+'''
				AND o.name = '''+t.name+'''
				AND s.name = '''+s.name+'''
				)'existancecheck
,	'BEGIN
		ALTER INDEX [' + i.name + '] ON ['+SCHEMA_NAME(t.schema_id)+'].[' + T.name + '] DISABLE
	END' disablesql
,'	BEGIN
		ALTER INDEX [' + i.name + '] ON ['+SCHEMA_NAME(t.schema_id)+'].[' + T.name + '] REBUILD
	END' rebuildsql
,ROW_NUMBER() OVER(ORDER BY t.name,i.name) rownum
INTO #list
FROM sys.indexes i
INNER JOIN sys.tables t 
	ON i.object_id = t.object_id
INNER JOIN sys.schemas s
	ON t.schema_id = s.schema_id
WHERE I.type_desc = 'NONCLUSTERED'
AND t.name = @tbl
AND SCHEMA_NAME(t.schema_id) = @sch
--SELECT * FROM #list



--for looping through all indexes
DECLARE @i int = (SELECT MIN(rownum) FROM #list)
--to hold SQL that will be executed
DECLARE @sql NVARCHAR(MAX) = ''

--loop through indexes and disable/rebuild
WHILE @i <= (SELECT MAX(rownum) FROM #list)
	BEGIN
		--execute sql to disable indexes
		--increment loopw
			IF @type = 'DISABLE'
				BEGIN 
					SET @sql = (SELECT CONCAT(existancecheck,' ',disablesql) FROM #list WHERE rownum = @i)
				END
			ELSE IF @type = 'REBUILD'
				BEGIN
					SET @sql = (SELECT CONCAT(existancecheck,' ',rebuildsql) FROM #list WHERE rownum = @i)
				END
	
		EXEC sp_executesql @sql
		--PRINT @SQL
		--PRINT @i
		SET @i = @i+1
	END



END
