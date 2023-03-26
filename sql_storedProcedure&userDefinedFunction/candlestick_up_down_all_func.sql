CREATE FUNCTION [dbo].[candlestick_up_down_all] (
     @company VARCHAR(10)
)
RETURNS @result_table TABLE (
        company VARCHAR(10),
        date VARCHAR(10),
        up_down INT
    )
AS
BEGIN
    DECLARE @date_table TABLE ([date] date)
    DECLARE @date date


    DECLARE db_cursor CURSOR FOR  
    SELECT date FROM dbo.行事曆 WHERE day_of_stock != -1 AND date <= GETDATE() -- only get working day & all day before and equal to today
    OPEN db_cursor   
    FETCH NEXT FROM db_cursor INTO @date   

    WHILE @@FETCH_STATUS = 0   
    BEGIN

           INSERT INTO @result_table
           SELECT * from candlestick_up_down(@company, @date)

           FETCH NEXT FROM db_cursor INTO @date   
    END   

    CLOSE db_cursor   
    DEALLOCATE db_cursor
    

    RETURN;
END