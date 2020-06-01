USE [master]
GO

/****** Object:  StoredProcedure [dbo].[Unit_Testing_For_Stored_Proc_Phil]    Script Date: 5/15/2020 1:43:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Unit_Testing_For_Stored_Proc_Phil]

@DB1 NVARCHAR(25),
@DB2 NVARCHAR(25),
@schema1 NVARCHAR(25),
@schema2 NVARCHAR(25),
@table1 NVARCHAR(50),
@table2 NVARCHAR(50),
@procedurename NVARCHAR(100) = ''

AS

BEGIN


/****************************************************************************************
*		  Procedure Name: [dbo].[Unit_Testing_For_Stored_Proc]
*			  Created by:	Ghislain Ndike
*			  Created on: 05-03-2020
*		     Description:	Unit Testing For Stored Procs
*	  How to Run W Param:	EXEC master.[dbo].[Unit_Testing_For_Stored_Proc_Phil]
							@DB1 = 'BIAnalytics'	,@DB2 = 'BIAnalytics'
							,@schema1 = 'main'		,@schema2 = 'main'
							,@table1 = 'datedim'	,@table2 = 'datedim_Phil'
							,@procedurename = 'fakestoredprocname'
*	

* Change History
*
*	Modified Date	Modified By	 Description of change
*	=============	===========	 =========================================================
*	2020-05-13		pmcdaniel	 Changes to all sections to ensure tests work as expected
*	
******************************************************************************************/
	SET NOCOUNT ON;
PRINT  '/====================================================/'
PRINT CONCAT('NAME OF TESTER: ' , SUSER_SNAME())
PRINT CONCAT('TIME OF TESTING: ' , GETDATE())
PRINT CONCAT('PROCEDURE BEING TESTED: ' , @procedurename)

--------------------------------------------------------------------------
--Ensure that parameters that entered are all valid. If not, through error

--check @db1
IF NOT EXISTS
(
	SELECT
	*
	FROM master.sys.databases
	WHERE name = @DB1
)
BEGIN
	THROW 51000, 'The parameter supplied for @DB1 does not exist. Please enter a valid database name', 1;
END
--check @db2
IF NOT EXISTS
(
	SELECT
	*
	FROM master.sys.databases
	WHERE name = @DB2
)
BEGIN
	THROW 51000, 'The parameter supplied for @DB2 does not exist. Please enter a valid database name', 1;
END
--check @schema1
IF NOT EXISTS
(
	SELECT
	*
	FROM master.sys.schemas
	WHERE name = @schema1
)
BEGIN
	THROW 51000, 'The parameter supplied for @schema1 does not exist. Please enter a valid schema name', 1;
END
--check @schema2
IF NOT EXISTS
(
	SELECT
	*
	FROM master.sys.schemas
	WHERE name = @schema2
)
BEGIN
	THROW 51000, 'The parameter supplied for @schema2 does not exist. Please enter a valid schema name', 1;
END
--check @table1
DECLARE @sql NVARCHAR(MAX) = ''
SET @sql =  CONCAT('IF NOT EXISTS(','SELECT s.name,t.name FROM [',@DB1,'].[sys].[tables] t INNER JOIN [',@DB1,'].[sys].[schemas] s on t.schema_id = s.schema_id WHERE t.name = ','''',@table1,'''',' AND s.name = ','''',@schema1,'''',')','BEGIN THROW 51000, ''The parameter supplied for @table1 does not exist. Please enter a valid table name'', 1;END')
--PRINT @sql
EXEC sp_executesql @sql

--check @table2
SET @sql = ''
SET @sql =  CONCAT('IF NOT EXISTS(','SELECT s.name,t.name FROM [',@DB2,'].[sys].[tables] t INNER JOIN [',@DB2,'].[sys].[schemas] s on t.schema_id = s.schema_id WHERE t.name = ','''',@table2,'''',' AND s.name = ','''',@schema2,'''',')','BEGIN THROW 51000, ''The parameter supplied for @table2 does not exist. Please enter a valid table name'', 1;END')
--PRINT @sql
EXEC sp_executesql @sql

PRINT  '/====================================================/'
PRINT '**************************************** SUMMARY OF TEST *********************************************'
PRINT  'FOR TEST STEP 1: VALIDATE RECORD COUNT ON BOTH TABLES ------------ Record count for both tables compare must match to PASS'
PRINT  'FOR TEST STEP 2: COMPARE TABLES SCHEMA FOR BOTH TABLES USING SYS.COLUMNS ------------ Zero rows affected means No Schema diff to PASS'
PRINT  'FOR TEST STEP 3: TABLE DATA ON BOTH TABLE1 & TABLE2 USING EXCEPT CLAUSE ------------ Zero rows affected means No Schema diff to PASS'
--PRINT  'FOR TEST STEP 4: VALIDATE RECORD COUNT ON BOTH TABLES ------------ Record count for both tables compare must match to PASS'
PRINT  '/====================================================/'
/*** Uncomment for Ideal scenario  ***/
--DECLARE @tableA sysname		= '[IHS].[EngagedFact]'
--DECLARE @tableB sysname		= '[IHS].[EngagedFact]' 

--------------------------------------------------------------------------

DROP TABLE IF EXISTS #myTableVariable__A;
DROP TABLE IF EXISTS #myTableVariable__B

-- Declare var for table name: DB + Schema + Tablename
DECLARE @wholetablenameA nvarchar(100)
DECLARE @wholetablenameB nvarchar(100)

SET @wholetablenameA = CONCAT('[',@db1,'].','[',@schema1,'].','[',@table1,']');
SET @wholetablenameB = CONCAT('[',@db2,'].','[',@schema2,'].','[',@table2,']');

PRINT 'OBJECTS BEING COMPARED';
PRINT  '/====================================================/'
PRINT @wholetablenameA;
PRINT @wholetablenameB;
PRINT  '/====================================================/'
;


DECLARE @sqlString NVARCHAR(MAX)
DECLARE @reportVar int = 0;
PRINT '======= TEST STEP 1: VALIDATE RECORD COUNT ON BOTH TABLES  =========='
;
		BEGIN TRY
		DECLARE @count1 int
		DECLARE @ParmDef NVARCHAR(MAX);

		SET @ParmDef = N'@count1out int OUTPUT';
		SET @sqlString = CONCAT('SELECT @count1out = COUNT(*) FROM ', @wholetablenameA)

		--PRINT @sqlString

		EXECUTE sp_executesql
		 @SQLString
		,@ParmDef
		,@count1out = @count1 OUTPUT;
		--SELECT @count1;
		
		
		DECLARE @count2 int
		SET @ParmDef = N'@count2out int OUTPUT';
		SET @sqlString = CONCAT('SELECT @count2out = COUNT(*) FROM ', @wholetablenameB)

		--PRINT @sqlString

		EXECUTE sp_executesql
		 @SQLString
		,@ParmDef
		,@count2out = @count2 OUTPUT;
		--SELECT @count2;


	END TRY

	BEGIN CATCH
		THROW 51000, 'Error occurred in the COUNT comparison', 1;
	END CATCH



PRINT
'/--------------------------------------------------/'
	BEGIN TRY
		 IF @count1 > @count2
			BEGIN
			SET @reportVar = (SELECT @count1 - @count2);
				PRINT (FORMAT( @reportVar,'N0') + ' NUMBER OF RECORDS EXISTS IN TABLE1 BUT MISSING IN TABLE2')
				PRINT '/-------------------------------------------------/'
				PRINT '					TEST FAILED '
				PRINT '/-------------------------------------------------/'
			END;
	 
		IF @count1 < @count2
			BEGIN
			SET @reportVar = (SELECT @count2 - @count1);
				PRINT (FORMAT( @reportVar,'N0') + ' NUMBER OF RECORDS EXISTS IN TABLE2 BUT MISSING IN TABLE1')
				PRINT '/-------------------------------------------------/'
				PRINT '					TEST FAILED'
				PRINT '/-------------------------------------------------/'

			END;
		 IF @count1 = @count2
			BEGIN
				PRINT ( FORMAT( @count1,'N0') + ' RECORDS IN TABLE1 AND ' + FORMAT( @count2,'N0') + ' RECORDS IN TABLE2')
				PRINT ('NUMBER OF RECORDS IN BOTH TABLE1 & TABLE2 MATCH')
				PRINT '/-------------------------------------------------/'
				PRINT '					TEST PASSED '
				PRINT '/-------------------------------------------------/'
			END;

	END TRY

	BEGIN CATCH
		 THROW 51000, 'Rowcount comparison failed', 1;
	END CATCH

PRINT '======= TEST STEP 2: COMPARE TABLES SCHEMA FOR BOTH TABLES USING SYS.COLUMNS ==========' 
;

--dynamic sql for column list for table1
SET @sql = ''
SET @sql = CONCAT
(' IF OBJECT_ID(''tempdb..##DBSchemaA'',''U'') IS NOT NULL BEGIN DROP TABLE ##DBSchemaA END
   SELECT c.name,ROW_NUMBER() OVER(ORDER BY c.name) rownum INTO ##DBSchemaA FROM [',@DB1,'].[sys].[tables] t INNER JOIN [',@DB1,'].[sys].[schemas] s on t.schema_id = s.schema_id INNER JOIN [',@DB1,'].[sys].[columns] c ON t.object_id = c.object_id WHERE t.name = ','''',@table1,'''',' AND s.name = ','''',@schema1,'''',' AND c.name NOT IN (''DateAdded'',''DateEdited'',''UserAdded'',''UserEdited'')'
)
--PRINT @sql
EXEC sp_executesql @sql
--SELECT * FROM ##DBSchemaA


--dynamic sql for column list for table2
SET @sql = ''
SET @sql = CONCAT
(' IF OBJECT_ID(''tempdb..##DBSchemaB'',''U'') IS NOT NULL BEGIN DROP TABLE ##DBSchemaB END
   SELECT c.name,ROW_NUMBER() OVER(ORDER BY c.name) rownum INTO ##DBSchemaB FROM [',@DB2,'].[sys].[tables] t INNER JOIN [',@DB2,'].[sys].[schemas] s on t.schema_id = s.schema_id INNER JOIN [',@DB2,'].[sys].[columns] c ON t.object_id = c.object_id WHERE t.name = ','''',@table2,'''',' AND s.name = ','''',@schema2,'''',' AND c.name NOT IN (''DateAdded'',''DateEdited'',''UserAdded'',''UserEdited'')'
)
--PRINT @sql
EXEC sp_executesql @sql
--SELECT * FROM ##DBSchemaB
;

--check to see if column list is the same
--columns that exist in one table, but not the other go into #coldif
		IF OBJECT_ID('tempdb..#coldif') IS NOT NULL BEGIN DROP TABLE #coldif END
		SELECT x.name INTO #coldif
		FROM 
		(
			(SELECT name FROM ##DBSchemaA
			EXCEPT 
			SELECT name FROM ##DBSchemaB)
			UNION ALL	
			(SELECT name FROM ##DBSchemaB
			EXCEPT 
			SELECT name FROM ##DBSchemaA)
		) x
		
	IF NOT EXISTS
	(
		SELECT * FROM #coldif
	)
	BEGIN
		PRINT ('COMPARING SCHEMA OF BOTH TABLES USING ''sys.columns''')
		PRINT '/-------------------------------------------------/'
		PRINT '					TEST PASSED'
		PRINT '/-------------------------------------------------/'
	END;
	IF EXISTS
	(
		SELECT * FROM #coldif
	)
	BEGIN
		PRINT ('COMPARING SCHEMA OF BOTH TABLES USING ''sys.columns''')
		PRINT '/-------------------------------------------------/'
		PRINT '					TEST FAILED'
		PRINT '/-------------------------------------------------/'
	END;

---------------------------------------------------------------------------------------------


-- This will return rows of records in TABLE1 that are missing in TABLE_B
PRINT '======= TEST STEP 3: COMPARE TABLE DATA ON BOTH TABLE1 & TABLE2 USING EXCEPT CLAUSE ==========' 
-- 3. COMPARE DATA RECORDS FOR RECORD IN OLD PROD TABLE (TABLE1) WITH NEW TABLE (TABLE2)

--if test 2 failed (schema differences), test 3 is guaranteed to fail because we are comparing data using EXCEPT which needs same column list			
--shortcircuit to failure of test three
IF EXISTS
(
	SELECT * FROM #coldif
)
BEGIN
	PRINT ('TEST STEP 3 CANNOT BE COMPLETED BECAUSE TABLE1 & TABLE2 HAVE DIFFERENT COLUMNS SO DATA CANNOT BE COMPARED USING EXCEPT')
	PRINT '/-------------------------------------------------/'
	PRINT '					TEST FAILED '
	PRINT '/-------------------------------------------------/'
	GOTO CLEANUP
END

--column list is the same so we can actually run the test		
		BEGIN TRY

			--loop to get columns list from table1
			DECLARE @i int = 1
			DECLARE @cols1 NVARCHAR(MAX) = ''
			SET @sql = ''
			WHILE @i <= (SELECT MAX(rownum) FROM ##DBSchemaA)
				BEGIN
					SET @cols1 = @cols1 + (SELECT name FROM ##DBSchemaA WHERE @i = rownum)+','
					SET @i = @i+1
					--PRINT @cols1
				END
			--lazy way to remove final ',' from column list
			SET @cols1 = SUBSTRING(@cols1,1,LEN(@cols1)-1)
			--PRINT @cols1
			SET @sql = CONCAT
			(
			 'IF OBJECT_ID(''tempdb..##table1'',''U'') IS NOT NULL BEGIN DROP TABLE ##table1 END '
			,'SELECT ',@cols1,' INTO ##table1 FROM ',@wholetablenameA
			)
			--PRINT @sql
			--load data into temp table
			EXEC sp_executesql @sql

			--loop to get column list from table2
			DECLARE @j int = 1
			DECLARE @cols2 NVARCHAR(MAX) = ''
			SET @sql = ''
			WHILE @j <= (SELECT MAX(rownum) FROM ##DBSchemaB)
				BEGIN
					SET @cols2 = @cols2 + (SELECT name FROM ##DBSchemaB WHERE @j = rownum)+','
					SET @j = @j+1
					--PRINT @cols1
				END
			--lazy way to remove final ',' from column list
			SET @cols2 = SUBSTRING(@cols2,1,LEN(@cols2)-1)
			--PRINT @cols1
			SET @sql = CONCAT
			(
			 'IF OBJECT_ID(''tempdb..##table2'',''U'') IS NOT NULL BEGIN DROP TABLE ##table2 END '
			,'SELECT ',@cols2,' INTO ##table2 FROM ',@wholetablenameB
			)
			--PRINT @sql
			--load data into temp table
			EXEC sp_executesql @sql
		END TRY

		BEGIN CATCH
			THROW 51000, 'There was an error found when creating the temp tables containing data from @table1 & @table2', 1;
		END CATCH

		--compare data between tables
		BEGIN TRY
			IF OBJECT_ID('tempdb..##compare1','U') IS NOT NULL BEGIN DROP TABLE ##compare1 END
			SELECT * INTO ##compare1 FROM ##table1
			EXCEPT
			SELECT * FROM ##table2
		END TRY
		BEGIN CATCH
			THROW 51000, '@table1 & @table2 have a different number of columns so they cannot be compared with EXCEPT', 1;
		END CATCH

		--compare data between tables
		BEGIN TRY
			IF OBJECT_ID('tempdb..##compare2','U') IS NOT NULL BEGIN DROP TABLE ##compare2 END
			SELECT * INTO ##compare2 FROM ##table2
			EXCEPT
			SELECT * FROM ##table1
		END TRY
		BEGIN CATCH
			THROW 51000, '@table1 & @table2 have a different number of columns so they cannot be compared with EXCEPT', 1;
		END CATCH

		--set count variables for failed test results
		
		BEGIN
			DECLARE @failcount1 int = (SELECT Count(*) FROM ##compare1)
			DECLARE @failcount2 int = (SELECT Count(*) FROM ##compare2)
		END;

PRINT
'/--------------------------------------------------/'
	
	--SUCCESS IS NOTHING IN EITHER ##compare1 or ##compare2
	IF (@failcount1 = 0 AND @failcount2 = 0)
	BEGIN
		PRINT (FORMAT(@count1,'N0') + ' ROWS WERE COMPARED BETWEEN TABLE1 AND TABLE2')
		PRINT ('ALL ROWS AND COLUMNS IN BOTH TABLE1 & TABLE2 MATCH EXACTLY')
		PRINT '/-------------------------------------------------/'
		PRINT '					TEST PASSED '
		PRINT '/-------------------------------------------------/'
	END

	--FAILURE IS SOMETHING IN EITHER ##compare1 or ##compare2
	IF NOT (@failcount1 = 0 AND @failcount2 = 0)
	BEGIN
		PRINT (FORMAT(@failcount1 ,'N0') + ' ROWS EXISTS IN TABLE1 BUT MISSING IN TABLE2')
		PRINT (FORMAT(@failcount2 ,'N0') + ' ROWS EXISTS IN TABLE2 BUT MISSING IN TABLE1')
		PRINT '/-------------------------------------------------/'
		PRINT '					TEST FAILED '
		PRINT '/-------------------------------------------------/'
	END


CLEANUP:
-- CLEAN UP temp tables
IF OBJECT_ID('tempdb..#myTableVariable__A','U') IS NOT NULL BEGIN DROP TABLE #myTableVariable__A END
IF OBJECT_ID('tempdb..#myTableVariable__B','U') IS NOT NULL BEGIN DROP TABLE #myTableVariable__B END
IF OBJECT_ID('tempdb..##DBSchemaA','U') IS NOT NULL BEGIN DROP TABLE ##DBSchemaA END
IF OBJECT_ID('tempdb..##DBSchemaB','U') IS NOT NULL BEGIN DROP TABLE ##DBSchemaB END
IF OBJECT_ID('tempdb..##table1','U') IS NOT NULL BEGIN DROP TABLE ##table1 END
IF OBJECT_ID('tempdb..##table2','U') IS NOT NULL BEGIN DROP TABLE ##table2 END
IF OBJECT_ID('tempdb..##compare1','U') IS NOT NULL BEGIN DROP TABLE ##compare1 END
IF OBJECT_ID('tempdb..##compare2','U') IS NOT NULL BEGIN DROP TABLE ##compare2 END
END
GO