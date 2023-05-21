ALTER FUNCTION dbo.find_Ma_up_down
(
    @stock_code varchar(10),
    @interval int, --往前抓的天數
    @change_interval int --決定上升或下降的天數，若沒有則視為平緩趨勢
)
RETURNS @MA_updown_trend TABLE
(
	stock_code varchar(10),
	date date,
	yesterday_c real,
	today_c	 real,
	yesterday_MA real,
	today_MA real, 
	MA_diff INT, /* 判斷今日與昨日的MA為正或負 */
	trend INT, 	/* 1為上漲、-1為下跌、0為盤整 */
	counter_plus int,  /* 數前幾天共有多少今日MA>昨日MA */
	counter_minus int  /* 數前幾天共有多少今日MA<昨日MA */
)
AS
BEGIN
	/* 將公司、日期、MA20、昨日的MA20放入回傳的表中*/
	/* your code here */
	INSERT INTO @MA_updown_trend(stock_code, date, today_c, today_MA, yesterday_c, yesterday_MA) SELECT stock_code, date, c, MA20, LAG(c,1,0) OVER(Order by date asc), LAG(MA20,1,0) over(order by date asc) from dbo.股價資訊 where stock_code = @stock_code order by [date]
	
	/*更新MA_diff，若今天MA>昨日MA，則為1，反之則為-1*/
	UPDATE @MA_updown_trend
	SET MA_diff = 
	CASE
		WHEN date ='2022-01-03' THEN 0
		WHEN today_MA > yesterday_MA THEN 1
		WHEN today_MA < yesterday_MA THEN -1
		ELSE 0
	END

	DECLARE cur CURSOR LOCAL for
		SELECT date FROM @MA_updown_trend order by date asc
	open cur

	DECLARE @diff_plus INT
	DECLARE @diff_minus INT
	DECLARE @date_tmp date


	FETCH next from cur into @date_tmp

	WHILE @@FETCH_STATUS = 0 BEGIN

		/* your code here */
		/* 計算前面幾天有多少今日MA>昨日MA */
        SELECT @diff_plus = SUM(MA_diff) from @MA_updown_trend WHERE date in (SELECT date from dbo.find_date(@date_tmp, @interval, 1, 0)) and MA_diff = 1 
		
		
		/* 計算前面幾天有多少今日MA<昨日MA */
        SELECT @diff_minus = ABS(SUM(MA_diff)) from @MA_updown_trend WHERE date in (SELECT date from dbo.find_date(@date_tmp, @interval, 1, 0)) and MA_diff = -1 

		
		
		/* 判斷上漲、下跌、平緩趨勢 */
        UPDATE @MA_updown_trend
	    SET trend = 
	    CASE
		    WHEN @diff_plus >= @change_interval THEN 1
		    WHEN @diff_minus >= @change_interval THEN -1
		    ELSE 0
	    END where date = @date_tmp

        UPDATE @MA_updown_trend
        set counter_plus = @diff_plus, counter_minus = @diff_minus WHERE date = @date_tmp

		
		
		/* 更新 @MA_updown_trend */



		FETCH next from cur into @date_tmp
	END
	CLOSE cur
	DEALLOCATE cur 
	return
END