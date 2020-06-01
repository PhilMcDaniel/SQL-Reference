SELECT 
SCHEMA_NAME(t.schema_id) SchemaName
,t.NAME AS TableName
,i.name AS indexName
,CASE
  WHEN i.index_id=0 THEN 'Heap' 
  ELSE 'Clustered' 
END as TableType
,SUM(p.rows) AS RowCounts
,SUM(a.total_pages) AS TotalPages
,SUM(a.used_pages) AS UsedPages
,SUM(a.data_pages) AS DataPages
,(SUM(a.total_pages) * 8) / 1024 AS TotalSpaceMB
,(SUM(a.used_pages) * 8) / 1024 AS UsedSpaceMB
,(SUM(a.data_pages) * 8) / 1024 AS DataSpaceMB
FROM 
sys.tables t
INNER JOIN sys.indexes i 
	ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p 
	ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a 
	ON p.partition_id = a.container_id
WHERE 
t.NAME NOT LIKE 'dt%' AND
i.OBJECT_ID > 255 AND  
i.index_id <= 1
--AND i.index_id = 0
GROUP BY
SCHEMA_NAME(t.schema_id),t.NAME, i.object_id, i.index_id, i.name
ORDER BY (SUM(a.used_pages) * 8) / 1024 DESC


