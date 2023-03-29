ALTER PROCEDURE [dbo].[MA_Analysis]
    @stock_code VARCHAR(10),
    @MA1 VARCHAR(5),
    @MA2 VARCHAR(5),
    @result VARCHAR(200) OUTPUT
AS
BEGIN

    SET NOCOUNT ON
    DECLARE @CountResults TABLE (MA1 REAL, MA2 REAL)
    DECLARE @sqlStatement VARCHAR(900) = 'SELECT ' + @MA1 + ', ' + @MA2 + '  FROM dbo.股價資訊 WHERE stock_code = '+@stock_code+' ORDER BY [date] DESC' 
    INSERT @CountResults
    EXEC(@sqlStatement)
    
    DECLARE @MA_1 REAL
    DECLARE @MA_2 REAL
    DECLARE @day int
    DECLARE @trend int
    DECLARE @daily_trend int

    DECLARE cur CURSOR LOCAL FOR
    SELECT MA1, MA2 FROM @CountResults

    OPEN cur
    FETCH NEXT FROM cur INTO @MA_1, @MA_2
    SET @day = 0

    WHILE @@FETCH_STATUS = 0 BEGIN

        if(@MA_1 > @MA_2)
            set @daily_trend = 1
        ELSE IF(@MA_1 < @MA_2)
            SET @daily_trend = -1
        ELSE
            SET @daily_trend = 0

        IF(@day = 0)
            SET @trend = @daily_trend
        ELSE IF(@daily_trend != @trend)
            break

        SET @day = @day + 1
        FETCH NEXT FROM cur INTO @MA_1, @MA_2
    END
    if(@trend = 1)
        SET @result = @MA1 + ' over ' + @MA2 + ' ' + CAST(@day AS VARCHAR) + ' days'
    ELSE IF(@trend = -1)
        SET @result = @MA1 + ' under ' + @MA2 + ' ' + CAST(@day AS VARCHAR) + ' days'
    ELSE
        SET @result = ''
    
    CLOSE cur
    DEALLOCATE cur
END