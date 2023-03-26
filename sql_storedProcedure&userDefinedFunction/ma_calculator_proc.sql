ALTER PROCEDURE dbo.MA_Calculator
    @date VARCHAR(10),
    @stock_code VARCHAR(10)
AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE @MA5 real
    DECLARE @MA10 real
    DECLARE @MA20 real
    DECLARE @MA60 real
    DECLARE @MA120 real
    DECLARE @MA240 real

    SELECT @MA5 = AVG(c) FROM dbo.股價資訊 WHERE date in (SELECT date from dbo.find_date(@date, 5, 1, 1)) AND stock_code = @stock_code
    SELECT @MA10 = AVG(c) FROM dbo.股價資訊 WHERE date in (SELECT date from dbo.find_date(@date, 10, 1, 1)) AND stock_code = @stock_code
    SELECT @MA20 = AVG(c) FROM dbo.股價資訊 WHERE date in (SELECT date from dbo.find_date(@date, 20, 1, 1)) AND stock_code = @stock_code
    SELECT @MA60 = AVG(c) FROM dbo.股價資訊 WHERE date in (SELECT date from dbo.find_date(@date, 60, 1, 1)) AND stock_code = @stock_code
    SELECT @MA120 = AVG(c) FROM dbo.股價資訊 WHERE date in (SELECT date from dbo.find_date(@date, 120, 1, 1)) AND stock_code = @stock_code
    SELECT @MA240 = AVG(c) FROM dbo.股價資訊 WHERE date in (SELECT date from dbo.find_date(@date, 240, 1, 1)) AND stock_code = @stock_code
    
    UPDATE 股價資訊
    SET MA5 = @MA5 WHERE date = @date AND stock_code = @stock_code
    UPDATE 股價資訊
    SET MA10 = @MA10 WHERE date = @date AND stock_code = @stock_code
    UPDATE 股價資訊
    SET MA20 = @MA20 WHERE date = @date AND stock_code = @stock_code
    UPDATE 股價資訊
    SET MA60 = @MA60 WHERE date = @date AND stock_code = @stock_code
    UPDATE 股價資訊
    SET MA120 = @MA120 WHERE date = @date AND stock_code = @stock_code
    UPDATE 股價資訊
    SET MA240 = @MA240 WHERE date = @date AND stock_code = @stock_code

END