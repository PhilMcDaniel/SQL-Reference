SELECT 
[Name]
,[Path]
,[CreationDate]
,[ModifiedDate]
,CAST(CAST(Content AS VARBINARY(MAX)) AS XML) AS ReportXML
--query will be in <DataSets> tag
FROM [ReportServer].dbo.[Catalog]
WHERE Type = 2
ORDER BY [Name]