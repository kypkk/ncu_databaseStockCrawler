CREATE PROCEDURE dbo.Trend_Analysis
    @stock_code VARCHAR(10),
    @day int OUTPUT,
    @result VARCHAR(50) OUTPUT
AS
BEGIN

    SET NOCOUNT ON
    DECLARE @c REAL
    DECLARE @MA5 REAL
    DECLARE @MA10 REAL
    DECLARE @MA20 REAL
    DECLARE @trend int
    DECLARE @daily_trend int

    DECLARE cur CURSOR LOCAL FOR
    SELECT c, MA5, MA10, MA20 FROM dbo.股價資訊 WHERE stock_code = @stock_code ORDER BY [date] DESC

    OPEN cur
    FETCH NEXT FROM cur INTO @c, @MA5, @MA10, @MA20
    SET @day = 0

    WHILE @@FETCH_STATUS = 0 BEGIN

        if(@c > @MA5 and @MA5 > @MA10 and @MA10 > @MA20)
            set @daily_trend = 1
        ELSE IF(@c < @MA5 and @MA5 < @MA10 and @MA10 < @MA20)
            SET @daily_trend = -1
        ELSE
            SET @daily_trend = 0

        IF(@day = 0)
            SET @trend = @daily_trend
        ELSE IF(@daily_trend != @trend)
            break

        SET @day = @day + 1
        FETCH NEXT FROM cur INTO @c, @MA5, @MA10, @MA20
    END
    if(@trend = 1)
        SET @result = 'Up Trend'
    ELSE IF(@trend = -1)
        SET @result = 'Down Trend'
    ELSE
        SET @result = 'Consolidate'
    
    CLOSE cur
    DEALLOCATE cur
END