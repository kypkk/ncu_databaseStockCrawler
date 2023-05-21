ALTER function find_max_min
(
    @stock_code VARCHAR(10)
)returns @max_min_table TABLE
(
    date date,
    close_price real,
    max_min int
)
AS
BEGIN
    Declare @Trend AS TABLE
    (
        date date not NULL,
        stock_code VARCHAR(10) NOT NULL,
        MA_price real,
        close_price real NOT NULL,
        /* MA, close price 比較 */
        point_region INT,
        /*  臨界點*/
        crossover_point INT,
        /* 目前趨勢*/
        cur_trend INT,
        /* 未來日期中MA與close price的變化天數*/
        counter INT
    )
    
    INSERT INTO @trend(date, stock_code, MA_price, close_price, point_region, crossover_point, cur_trend, counter)
    Select date, stock_code, MA_price, close_price, point_region, crossover_point, cur_trend, counter FROM dbo.find_crossover_date(@stock_code, 3) order by [date]
    
    DECLARE cur CURSOR LOCAL FOR
        select date, close_price, cur_trend from @Trend order by [date]
    open cur

    DECLARE @return_date date
    DECLARE @max_min_close_tmp real
    DECLARE @max_min_tmp int

    DECLARE @date_tmp date
    DECLARE @close_tmp REAL
    DECLARE @trend_tmp INT

    FETCH NEXT from cur into @date_tmp, @close_tmp, @trend_tmp
    SET @max_min_close_tmp = @close_tmp
    SET @max_min_tmp = @trend_tmp

    WHILE @@FETCH_STATUS = 0 BEGIN
    
        if @max_min_tmp != @trend_tmp
        BEGIN
            INSERT INTO @max_min_table(date, close_price, max_min) SELECT @return_date, @max_min_close_tmp, @max_min_tmp
            SET @max_min_tmp = @trend_tmp
            SET @max_min_close_tmp = @close_tmp
            set @return_date = @date_tmp
        END


        IF @max_min_tmp = 1
        BEGIN
            IF @close_tmp > @max_min_close_tmp
            BEGIN
                set @max_min_close_tmp = @close_tmp
                set @return_date = @date_tmp
            END
        END
        ELSE IF @max_min_tmp = 0
        BEGIN 
            IF @close_tmp < @max_min_close_tmp
            BEGIN
                set @max_min_close_tmp = @close_tmp
                set @return_date = @date_tmp
            END
        END


        FETCH NEXT from cur into @date_tmp, @close_tmp, @trend_tmp

    END
    CLOSE cur
    DEALLOCATE cur
    return
END