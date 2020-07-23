SELECT
s.name as SchemaName
,t.name as TableWithForeignKey 
,c.name as ForeignKeyColumn
,o.name ConstraintName
,CONCAT('ALTER TABLE ',s.name,'.',t.name,' NOCHECK CONSTRAINT ',o.name) NocheckSQL
,CONCAT('ALTER TABLE ',s.name,'.',t.name,' CHECK CONSTRAINT ',o.name) CheckSQL
FROM sys.foreign_key_columns as fk
INNER JOIN sys.tables t 
	ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas s
	ON t.schema_id = s.schema_id
INNER JOIN sys.columns c 
	ON fk.parent_object_id = c.object_id 
	AND fk.parent_column_id = c.column_id
INNER JOIN sys.objects o
	ON fk.constraint_object_id = o.object_id
WHERE 
fk.referenced_object_id = (	SELECT object_id 
                            FROM sys.tables 
                            WHERE name = 'GroupDim')
ORDER BY
s.name,t.name,o.name