SELECT 
O.Operation_Id
,E.Folder_Name
,E.Project_name
,EM.Package_Name 
,CONVERT(DATETIME, O.start_time) AS Start_Time 
,CONVERT(DATETIME, O.end_time) AS End_Time 
,OM.message as [Error_Message] 
,EM.Event_Name 
,EM.Message_Source_Name AS Component_Name 
,EM.Subcomponent_Name AS Sub_Component_Name 
,E.Environment_Name 
,EM.Package_Path 
,E.Executed_as_name AS Executed_By 
FROM [SSISDB].[internal].[operations] O 
INNER JOIN [SSISDB].[internal].[event_messages] EM 
ON o.start_time >=  '2021-01-05'
AND EM.operation_id = O.operation_id 
INNER JOIN [SSISDB].[internal].[operation_messages] OM
	ON EM.operation_id = OM.operation_id 
INNER JOIN [SSISDB].[internal].[executions] E 
	ON OM.Operation_id = E.EXECUTION_ID 
WHERE OM.Message_Type = 120 -- 120 means Error 
AND EM.event_name = 'OnError' 
AND EM.Message_Source_Name LIKE '%exec%'
ORDER BY EM.operation_id DESC