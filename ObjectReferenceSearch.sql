-- =============================================
-- Author:		Phil McDaniel
-- Create date: 2020-06-17
-- Description:	Searches through all databases to find object dependencies
-- Example: EXEC [AuditDatabase].[usp_FindDepenencies] @object = 'Datedim', @type = 'all'
-- =============================================
CREATE PROCEDURE [AuditDatabase].[usp_FindDepenencies]
@object VARCHAR(100),@type VARCHAR(20)
AS
BEGIN

SET NOCOUNT ON;


DECLARE @ed VARCHAR (100) = ''
DECLARE @sql NVARCHAR(MAX) = ''
DECLARE @ParmDefinition NVARCHAR(500) = '@dynvar VARCHAR(100)'


IF OBJECT_ID('tempdb..#dbs','U') IS NOT NULL BEGIN DROP TABLE #dbs END
SELECT name dbname,ROW_NUMBER() OVER(ORDER BY database_id) rownum
INTO #dbs
FROM master.sys.databases
WHERE state_desc != 'OFFLINE'
--SELECT * FROM #dbs

IF OBJECT_ID('tempdb..#refs','U') IS NOT NULL BEGIN DROP TABLE #refs END
CREATE TABLE #refs
(
referencing_database_name VARCHAR(100)
,referencing_schema_name VARCHAR(100)
,referencing_entity_name VARCHAR(100)
,referencing_object_type VARCHAR(100)
,referenced_database_name VARCHAR(100)
,referenced_schema_name VARCHAR(100)
,referenced_entity_name VARCHAR(100)
,referenced_object_type VARCHAR(100)
,reference_type			VARCHAR(20)
)
--SELECT * FROM #refs

DECLARE @i INT = 1
WHILE @i <= (SELECT MAX(rownum) FROM #dbs)
BEGIN
	SET @sql = ''
	SET @sql = (SELECT CONCAT('
	INSERT INTO #refs (referencing_database_name, referencing_schema_name,referencing_entity_name,referencing_object_type,referenced_database_name,referenced_schema_name,referenced_entity_name,referenced_object_type,reference_type)
	SELECT '
	,'''',dbname,'''','referencing_database_name,ings.name referencing_schema_name, ingo.name referencing_entity_name,ingo.type_desc referencing_object_type
	,ISNULL(referenced_database_name,','''',dbname,'''',') referenced_database_name,referenced_schema_name,referenced_entity_name,edo.type_desc referenced_object_type,''referencing''
	FROM [',dbname,'].sys.sql_expression_dependencies dep
	INNER JOIN [',dbname, '].sys.all_objects ingo
		ON dep.referencing_id = ingo.object_id
	LEFT OUTER JOIN [',dbname, '].sys.all_objects edo
		ON dep.referenced_id = edo.object_id
	INNER JOIN [',dbname, '].sys.schemas ings
		ON ingo.schema_id = ings.schema_id
	WHERE ingo.name = @dynvar
	UNION ALL
	SELECT '
	,'''',dbname,'''','referencing_database_name,ings.name referencing_schema_name, ingo.name referencing_entity_name,ingo.type_desc referencing_object_type
	,ISNULL(referenced_database_name,','''',dbname,'''',') referenced_database_name,referenced_schema_name,referenced_entity_name,edo.type_desc referenced_object_type,''referenced''
	FROM [',dbname,'].sys.sql_expression_dependencies dep
	INNER JOIN [',dbname, '].sys.all_objects ingo
		ON dep.referencing_id = ingo.object_id
	LEFT OUTER JOIN [',dbname, '].sys.all_objects edo
		ON dep.referenced_id = edo.object_id
	INNER JOIN [',dbname, '].sys.schemas ings
		ON ingo.schema_id = ings.schema_id
	WHERE dep.referenced_entity_name = @dynvar
	')
	FROM #dbs WHERE rownum = @i
	)
	--PRINT @sql

	--need to use same parameter(s) as above to pass in value
	BEGIN TRY
		EXEC sp_executesql @sql,@ParmDefinition,@dynvar = @object
	END TRY
	BEGIN CATCH
		PRINT 'ERROR EXECUTING DYNAMIC SQL';
		THROW
	END CATCH
	
	SET @i = @i + 1
END;

WITH cte
AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY referencing_database_name, referencing_schema_name,referencing_entity_name,referenced_database_name,referenced_schema_name,referenced_entity_name,reference_type ORDER BY referenced_entity_name)rownum FROM #refs
)
DELETE FROM cte WHERE rownum > 1

IF @type = 'all'
BEGIN
	SELECT * FROM #refs ORDER BY 1,2,3,5,6,7
END
IF @type = 'referenced'
BEGIN
	SELECT * FROM #refs WHERE reference_type = @type ORDER BY 1,2,3,5,6,7
END
IF @type = 'referencing'
BEGIN
	SELECT * FROM #refs WHERE reference_type = @type ORDER BY 1,2,3,5,6,7
END

END