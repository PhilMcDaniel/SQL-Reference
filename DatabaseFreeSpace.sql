SELECT [TYPE] = A.type_desc, 
       [FILE_Name] = A.NAME, 
       [FILEGROUP_NAME] = fg.NAME, 
       [File_Location] = A.physical_name, 
       [FILESIZE_MB] = CONVERT(DECIMAL(10, 2), A.size / 128.0), 
       [USEDSPACE_MB] = CONVERT(DECIMAL(10, 2), A.size / 128.0 - ( 
                                                ( size / 128.0 ) - Cast( 
                                                Fileproperty(A.NAME, 
                                                'SPACEUSED') AS 
                                                INT 
                                                ) / 128.0 )), 
       [FREESPACE_MB] = CONVERT(DECIMAL(10, 2), A.size / 128.0 - Cast( 
                                                Fileproperty(A.NAME, 'SPACEUSED' 
                                                ) 
                                                                 AS INT) / 128.0 
                        ), 
       [FREESPACE_%] = CONVERT(DECIMAL(10, 2), ( ( A.size / 128.0 - Cast( 
                                                   Fileproperty(A.NAME, 
                                                   'SPACEUSED') AS 
       INT) / 128.0 ) / 
       ( 
       A.size / 128.0 ) ) * 100), 
       [AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN Cast(growth/128 
                    AS 
                    VARCHAR(10)) + 
                    ' MB -' WHEN 1 THEN Cast(growth AS VARCHAR(10)) + '% -' ELSE 
                    '' END 
                    + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN 
                    ' Unrestricted' 
                    ELSE ' Restricted to ' + Cast(max_size/(128*1024) AS VARCHAR 
                    (10)) + 
                    ' GB' END + CASE is_percent_growth WHEN 1 THEN 
                    ' [autogrowth by percent, BAD setting!]' ELSE '' END 
FROM   sys.database_files A 
       LEFT JOIN sys.filegroups fg 
              ON A.data_space_id = fg.data_space_id 
ORDER  BY A.type DESC, 
          A.NAME;