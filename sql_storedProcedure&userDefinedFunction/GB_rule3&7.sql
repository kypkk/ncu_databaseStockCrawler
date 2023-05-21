ALTER FUNCTION [dbo].[GB_rule3_7]
(
	@company varchar(10),
	@bias_threshold float, --回測乖離門檻值，要低於多少才算靠近均線
	@backward_day int,
	@backward_threshold float, --往回看收盤價差門檻值
	@forward_day int,
	@forward_threshold float --往後看收盤價差門檻值
)
RETURNS @rule_3 TABLE
(
	date date, --買入的時間
	Buy_or_sell int  --設buy為1、sell為-1  
)
AS
BEGIN
	/* 宣告暫存表 */
	DECLARE @temp_table TABLE
	(
		date date,
		today_c real,　
        yesterday_c real,
		today_MA real, 
		bias real,  --每日乖離
		trend int      --判斷現在為空頭、多頭趨勢
	)

	/* 將MA_trend資訊放入暫存表 */
	INSERT INTO @temp_table (date,today_c,today_MA,trend, yesterday_c)
	SELECT date,today_c,today_MA,trend, yesterday_c
	FROM find_MA_up_down(@company,8,6)

	/*更新bias值至@temp_table*/
    UPDATE @temp_table
    SET bias = ((today_c - today_MA) / today_MA )* 100


	/* 宣告cursor*/
	DECLARE cur CURSOR LOCAL for
		SELECT date,today_c,today_MA,bias,trend FROM @temp_table order by date asc
	open cur

	/* 宣告參數 */
	DECLARE @date DATE
	DECLARE @today_c REAL
	DECLARE @today_MA REAL
	DECLARE @today_bias REAL
	DECLARE @trend INT

    DECLARE @condition1 int
    DECLARE @condition2 int
	

	FETCH next from cur into @date,@today_c,@today_MA,@today_bias,@trend

	/* 開啟cursor，隔行check trend的變化*/
	WHILE @@FETCH_STATUS = 0 
	BEGIN
        set @condition1 = 0
        set @condition2 = 0
		DECLARE @return_date date = NULL

		/*  若目前為多頭趨勢，today_bias為正且小於閾值，表示K線回測均線，
            再往回看backward_day天是否股價價差%數高於backward_threshold，有則表示下跌情形，
            符合上述條件，就往後看forward_day天，須符合bias均為正，且有某天股價價差大於forward_threshold*/

		/* 趨勢為正且過度靠近均線 */
		IF(@trend = 1 AND @today_bias > 0 AND @today_bias < @bias_threshold)
                BEGIN
				/* 看前backward_day天的收盤價差否有高過@backward_threshold，以確認該天為下跌至均線附近 */
                Select @condition1 = 1 from @temp_table where date in (SELECT date from dbo.find_date_2(@date, @backward_day, 0, 1)) 
														AND ((today_c - @today_c) / @today_c) * 100 > @backward_threshold

				
				/* 看後forward_day是否有回升，收盤價差大於forward_threshold，且都沒有低過均線 */
                SELECT top(1) @condition2 = 1, @return_date = date  from @temp_table where date in (SELECT date from dbo.find_date_2(@date, @forward_day, 0, 0)) 
																					And ((today_c - @today_c) * 100 / @today_c) > @forward_threshold

                SELECT @condition2 = 0 from @temp_table where date in (SELECT date from dbo.find_date_2(@date, @backward_day, 0, 0)) and today_c <= today_MA

				/*確認該日期是否已經存在於表中*/
                INSERT @rule_3(date, Buy_or_sell) Select @return_date, 1 where @condition1 = 1 and @condition2 = 1 and @return_date NOT in (Select date from @rule_3)
				END
				
			
			
		/* 趨勢為負且過度靠近均線 */
		ELSE IF(@trend = -1 AND @today_bias < 0 AND abs(@today_bias) < @bias_threshold)
				BEGIN
				/* 看前backward_day天的收盤價差否有高過@backward_threshold，以確認該天為下跌至均線附近 */
                Select @condition1 = 1 from @temp_table where date in (SELECT date from dbo.find_date_2(@date, @backward_day, 0, 1)) 
														AND ((@today_c - today_c) / @today_c) * 100 > @backward_threshold

				
				/* 看後forward_day是否有回升，收盤價差大於forward_threshold，且都沒有低過均線 */
                SELECT top(1) @condition2 = 1, @return_date = date  from @temp_table where date in (SELECT date from dbo.find_date_2(@date, @forward_day, 0, 0)) 
																						And ((@today_c - today_c) * 100 / @today_c) > @forward_threshold

                SELECT @condition2 = 0 from @temp_table where date in (SELECT date from dbo.find_date_2(@date, @backward_day, 0, 0)) and today_c >= today_MA

				/*確認該日期是否已經存在於表中*/
                INSERT @rule_3(date, Buy_or_sell) Select @return_date, -1 where @condition1 = 1 and @condition2 = 1 and @return_date NOT in (Select date from @rule_3)
				END

		FETCH next from cur into @date,@today_c,@today_MA,@today_bias,@trend
	END
	close cur
	DEALLOCATE cur 
	return

END