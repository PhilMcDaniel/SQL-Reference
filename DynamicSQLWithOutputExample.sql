DECLARE @DB1 NVARCHAR(25),   ----- REQUIRED: For TABLE_A
@DB2 NVARCHAR(25),  ----- OPTIONAL: For TABLE_B
@schema1 NVARCHAR(25),	   ----- REQUIRED: For TABLE_B
@schema2 NVARCHAR(25),	   ----- REQUIRED: For TABLE_B
@table1 NVARCHAR(50),   ----- REQUIRED: For TABLE_A
@table2 NVARCHAR(50),	   ----- REQUIRED: For TABLE_B
@procedurename NVARCHAR(100) = ''

SET @db1 = 'BIAnalytics'
SET @db2 = 'BIAnalytics'
SET @schema1 = 'main'
SET @schema2 = 'main'
SET @table1 = 'datedim'
SET @table2 = 'datedim'
SET @procedurename = 'ExampleProcName'


DECLARE @sqlstring NVARCHAR(MAX)
DECLARE @wholetablenameA nvarchar(100)
DECLARE @count int

DECLARE @ParmDef NVARCHAR(MAX);  

SET @wholetablenameA = CONCAT('[',@db1,'].','[',@schema1,'].','[',@table1,']');

SET @ParmDef = N'@count1out int OUTPUT'; 
SET @sqlString = CONCAT('SELECT @count1out = COUNT(*) FROM ', @wholetablenameA)

PRINT @sqlString

EXECUTE sp_executesql  
 @SQLString  
,@ParmDefinition  
,@count1out = @count OUTPUT;  
SELECT @count; 