ALTER FUNCTION dbo.GB_rule5
(
    @stock_code varchar(10)
)
Returns @date_table TABLE
(
    date date,
    Buy_sell INT
)
AS
BEGIN
    DECLARE @MA_updown_trend AS TABLE(
        stock_code varchar(10),
        date date,
        yesterday_c real,
        today_c	 real,
        yesterday_MA real,
        today_MA real, 
        today_trend INT, 	/* 1為上漲、-1為下跌、0為盤整 */
        yesterday_trend INT /* 判斷今日與昨日的MA為正或負 */
    )
    INSERT INTO @MA_updown_trend(stock_code, date, today_c, today_MA, yesterday_c, yesterday_MA, today_trend, yesterday_trend) SELECT stock_code, date, today_c, today_MA, yesterday_c, yesterday_MA, trend, LAG(trend,1,0) OVER(Order by date asc) from dbo.find_MA_up_down(@stock_code, 8, 6) order by [date]
    
    DECLARE cur CURSOR LOCAL FOR
        select date, today_c, yesterday_c, today_MA, yesterday_MA, today_trend, yesterday_trend from @MA_updown_trend order by date
    open cur

    DECLARE @date_tmp date
    DECLARE @c REAL
    DECLARE @yesterday_c REAL
    DECLARE @MA REAL
    DECLARE @yesterday_MA REAL
    DECLARE @today_trend INT
    DECLARE @yesterday_trend INT

    FETCH next FROM cur into @date_tmp, @c, @yesterday_c, @MA, @yesterday_MA, @today_trend, @yesterday_trend

    WHILE @@FETCH_STATUS = 0 BEGIN

        if @c > @MA AND @today_trend = 0 AND @yesterday_trend = -1
            INSERT INTO @date_table(date, Buy_sell) select @date_tmp, 1
        
        if @c < @MA AND @today_trend = 0 AND @yesterday_trend = 1
            INSERT INTO @date_table(date, Buy_sell) select @date_tmp, -1
        

        FETCH next FROM cur into @date_tmp, @c, @yesterday_c, @MA, @yesterday_MA, @today_trend, @yesterday_trend

    END
	CLOSE cur
	DEALLOCATE cur 
	return
END