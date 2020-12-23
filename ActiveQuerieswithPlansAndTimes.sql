SELECT req.session_id,db.name database_name,ses.login_name,req.status,req.blocking_session_id,req.wait_type,req.wait_time wait_time_ms,req.command,req.start_time,req.cpu_time,req.total_elapsed_time runtime_ms,req.total_elapsed_time/60000 runtime_min,req.reads,req.logical_reads,req.writes,sqltext.TEXT,qp.query_plan 
FROM sys.dm_exec_requests req 
LEFT OUTER JOIN sys.dm_exec_sessions ses 
    ON req.session_id = ses.session_id 
LEFT OUTER JOIN sys.databases db 
     ON req.database_id = db.database_id 
CROSS APPLY sys.dm_exec_sql_text (sql_handle) AS sqltext 
CROSS APPLY sys.dm_exec_query_plan(req.plan_handle) AS QP 
ORDER BY req.session_id
