DECLARE    @date VARCHAR(10)
DECLARE    @stock_code VARCHAR(10)
DECLARE cur CURSOR LOCAL FOR
    SELECT date, stock_code FROM dbo.股價資訊
OPEN cur

FETCH NEXT FROM cur INTO @date, @stock_code

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC MA_Calculator @date, @stock_code
    FETCH NEXT FROM cur INTO @date, @stock_code
END

close cur
DEALLOCATE cur
