SELECT s.name,o.name,o.create_date,o.modify_date,m.definition
FROM sys.sql_modules m
inner join sys.objects o
	ON m.object_id = o.object_id
inner join sys.schemas s
	ON o.schema_id = s.schema_id
WHERE m.definition LIKE '%TRUNCATE%'
ORDER BY s.name,o.name