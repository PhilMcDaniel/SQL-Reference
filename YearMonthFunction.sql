CREATE FUNCTION [dbo].[YearMonths](@StartDate DateTime, @EndDate DateTime)
RETURNS @YearMonths table
(
[Year] int,
[Month] int,
[YearMonth] Char(6)
)
AS
BEGIN
    SET @EndDate = DATEADD(month, 1, @EndDate)
    WHILE (@StartDate < @EndDate)
    BEGIN

		INSERT INTO @YearMonths
		SELECT YEAR(@StartDate), MONTH(@StartDate),CONCAT(YEAR(@StartDate), RIGHT(CONCAT('00',MONTH(@StartDate)),2))

		SET @StartDate = DATEADD(month, 1, @StartDate)

    END

RETURN
END

--SELECT * FROM dbo.YearMonths('2020-01-01','2020-12-31')