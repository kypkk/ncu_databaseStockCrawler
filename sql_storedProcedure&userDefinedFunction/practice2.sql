ALTER FUNCTION find_date(@date NVARCHAR(10), @days INT, @isthatday BIT, @CNT BIT)
RETURNS @retTable TABLE
(
    date DATE,
    day_of_stock INT,
    other NVARCHAR(50)
)
    BEGIN
    declare @day_cnt INT
    SELECT @day_cnt = day_of_stock from dbo.行事曆 where date = @date
    IF @CNT = 0
        IF @isthatday = 1
            INSERT @retTable
            SELECT date, day_of_stock, other from dbo.行事曆
                where year(date) = year(@date)
                and @day_cnt - day_of_stock BETWEEN 0 and @days - 1
                and day_of_stock != -1
        ELSE
            INSERT @retTable
            SELECT date, day_of_stock, other from dbo.行事曆
                where year(date) = year(@date)
                and @day_cnt - day_of_stock BETWEEN 0 and @days
                and day_of_stock != -1
    ELSE
        IF @isthatday = 1
            INSERT @retTable
            SELECT date, day_of_stock, other from dbo.行事曆
                where year(date) = year(@date)
                and day_of_stock - @day_cnt BETWEEN 0 and @days - 1
                and day_of_stock != -1
        ELSE
            INSERT @retTable
            SELECT date, day_of_stock, other from dbo.行事曆
                where year(date) = year(@date)
                and day_of_stock - @day_cnt BETWEEN 0 and @days
                and day_of_stock != -1
    RETURN
    END;
    GO