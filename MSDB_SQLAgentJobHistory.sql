SELECT 
sh.instance_id
,j.job_id
,j.name as 'agent_jobname'
,CAST(CONCAT(LEFT(run_date,4),'-',SUBSTRING(CAST(run_date as varchar),5,2),'-',RIGHT(run_date,2)) as date) 'Rundate'
,sh.step_id
,sh.step_name
,CASE sh.run_status 
	WHEN 0 THEN 'Failed'  
	WHEN 1 THEN 'Succeeded'  
	WHEN 2 THEN 'Retry'  
	WHEN 3 THEN 'Canceled'  
	WHEN 4 THEN 'In Progress' 
END run_status
,CAST(RIGHT((RIGHT(REPLICATE('0', 6) +  CAST(sh.run_duration as varchar(6)), 6)),2) as int) + CAST(SUBSTRING(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_duration as varchar(6)), 6),3,2) as int)*60  + CAST(LEFT(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_duration as varchar(6)), 6),2) as int)*60*60 as 'run_duration_sec'
,STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(sh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') 'run_duration (DD:HH:MM:SS)'  ,STUFF(STUFF(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'start_time'
,CAST(CONCAT(LEFT(run_date,4),'-',SUBSTRING(CAST(run_date as varchar),5,2),'-',RIGHT(run_date,2))+' '+STUFF(STUFF(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') as datetime) as 'start_datetime'
,DATEADD(second,CAST(RIGHT((RIGHT(REPLICATE('0', 6) +  CAST(sh.run_duration as varchar(6)), 6)),2) as int) + CAST(SUBSTRING(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_duration as varchar(6)), 6),3,2) as int)*60  + CAST(LEFT(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_duration as varchar(6)), 6),2) as int)*60*60,CONCAT(LEFT(run_date,4),'-',SUBSTRING(CAST(run_date as varchar),5,2),'-',RIGHT(run_date,2))+' '+STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')) as 'end_datetime'
FROM msdb.dbo.sysjobhistory sh 
INNER JOIN msdb.dbo.sysjobs j 
	ON sh.job_id = j.job_id 
--WHERE j.name = 'LoadDataToBIAnalyticsStagingAndProductionMultiEnv_V2P'
ORDER BY sh.instance_id DESC