CREATE FUNCTION find_crossover_date(
    @stock_code VARCHAR(10),
    @change_interval INT
)
RETURNS @trend_tmp TABLE
(
    date date not NULL,
    stock_code VARCHAR(10) NOT NULL,
    MA_price real,
    close_price real NOT NULL,
    /**/
    point_region INT,
    /**/
    crossover_point INT,
    /**/
    cur_trend INT,
    /**/
    counter INT
)
AS
BEGIN

INSERT INTO @trend_tmp(date, stock_code, MA_price, close_price)
SELECT date, stock_code, MA5, c from dbo.股價資訊 where stock_code = @stock_code 
order by date desc

UPDATE @trend_tmp
set point_region = 0 where MA_price > close_price

UPDATE @trend_tmp
set point_region = 1 where MA_price <= close_price

DECLARE cur CURSOR LOCAL FOR
    select date, stock_code, point_region from @trend_tmp
open cur

DECLARE @current_trend INT
DECLARE @DAY_change_count INT

DECLARE @date_tmp date, @stock_code_tmp VARCHAR(10), @point_region_tmp int
FETCH NEXT from cur into @date_tmp, @stock_code_tmp, @point_region_tmp

SET @current_trend = @point_region_tmp
SET @DAY_change_count = 0

WHILE @@FETCH_STATUS = 0 BEGIN
    SELECT @DAY_change_count = COUNT(*)
    from @trend_tmp
    where point_region != @current_trend and date in (select date from find_date_2(@date_tmp, @change_interval, 1, 1))

    IF(@DAY_change_count >= @change_interval)
        BEGIN
            UPDATE @trend_tmp
            set crossover_point = 1
            where date = @date_tmp
            IF(@current_trend = 0)
                SET @current_trend = 1
            else
                SET @current_trend = 0
        END
    
    UPDATE @trend_tmp
    SET counter = @DAY_change_count, cur_trend = @current_trend where date = @date_tmp
    FETCH NEXT from cur into @date_tmp, @stock_code_tmp, @point_region_tmp

    END
    close cur
    DEALLOCATE cur
    RETURN
END