USE BIAnalytics
GO

--columns that are foreign keys but not indexed
--createidx column gives ddl for creating the index
SELECT
*
,CONCAT('CREATE NONCLUSTERED INDEX [idx_',col,']',' ON [',sch,'].[',tbl,'] ([',col,'] ASC)') createidx
FROM
(
	--all foreign keys
	SELECT
	SCHEMA_NAME(o.schema_id) 'sch'
	,OBJECT_NAME(o.parent_object_id) 'tbl'
	,c.name col
	FROM sys.all_objects o
	INNER JOIN sys.foreign_key_columns fk
		ON o.object_id = fk.constraint_object_id
	INNER JOIN sys.all_columns c
		ON fk.Parent_column_id = c.column_id
		AND fk.parent_object_id = c.object_id
	WHERE o.type = 'f'

	EXCEPT

	--all indexes
	SELECT
	SCHEMA_NAME(o.schema_id) 'sch'
	,o.name tbl
	,c.name col
	FROM sys.index_columns i
	INNER JOIN sys.all_columns c
		ON i.object_id = c.object_id
		AND i.column_id = c.column_id
	INNER JOIN sys.objects o
		ON i.object_id = o.object_id
	WHERE i.key_ordinal = 1
) x
ORDER BY sch,tbl,col