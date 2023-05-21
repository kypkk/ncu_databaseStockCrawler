create FUNCTION dbo.GB_rule2_6
(
    @stock_code varchar(10),
    @days int
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

    DECLARE @potential_date_up AS TABLE(
        date date,
        Buy int
    )

    DECLARE @potential_date_down AS TABLE(
        date date,
        Sell int 
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
    DECLARE @counter INT

    DECLARE @cs REAL
    DECLARE @MAs REAL
    DECLARE @dates date

    FETCH next FROM cur into @date_tmp, @c, @yesterday_c, @MA, @yesterday_MA, @today_trend, @yesterday_trend

    WHILE @@FETCH_STATUS = 0 BEGIN

        if @c < @MA AND @today_trend = 1 AND @yesterday_c > @yesterday_MA
            INSERT INTO @date_table(date, Buy_sell) SELECT top(1)date, 1 from @MA_updown_trend
            where date in(SELECT date from find_date_2(@date_tmp, @days,0,0)) and today_c > today_MA
            and date NOT in (select date from @date_table)
            
            
        if @c > @MA AND @today_trend = -1 AND @yesterday_c < @yesterday_MA
            INSERT INTO @date_table(date, Buy_sell) SELECT top(1)date, -1 from @MA_updown_trend
            where date in(SELECT date from find_date_2(@date_tmp, @days,0,0)) and today_c < today_MA
            and date NOT in (select date from @date_table)


        
        
        
        
        FETCH next FROM cur into @date_tmp, @c, @yesterday_c, @MA, @yesterday_MA, @today_trend, @yesterday_trend

    END
	CLOSE cur
	DEALLOCATE cur 
	return

    

END