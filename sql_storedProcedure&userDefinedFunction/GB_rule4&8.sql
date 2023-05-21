CREATE FUNCTION [dbo].[GB_rule4_8]
(
    @company varchar(10),
    @positive_bias_threshold float,
    @negative_bias_threshold float
)
RETURNS @result TABLE
(
    date date, --買入的時間
    buy_or_sell int  --設buy為1、sell為-1  
)
AS
BEGIN
    /* 宣告暫存表 */
    DECLARE @temp_table TABLE
    (
        date date,
        today_c real,　
        today_MA real, 
        bias real,  --每日乖離
        trend int      --判斷現在為空頭、多頭趨勢
    )

    /* 將MA_trend資訊放入暫存表 */
    INSERT INTO @temp_table (date,today_c,today_MA,trend)
    SELECT date,today_c,today_MA,trend 
    FROM find_MA_up_down(@company,8,6)

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
    

    FETCH next from cur into @date,@today_c,@today_MA,@today_bias,@trend

    /* 開啟cursor，隔行check trend的變化*/
    WHILE @@FETCH_STATUS = 0 
    BEGIN
        IF(@trend = 1 AND @today_bias > @positive_bias_threshold)
            BEGIN
                INSERT INTO @result VALUES(@date,1)
            END
        ELSE IF(@trend =-1 AND @today_bias < @negative_bias_threshold)
            BEGIN
                INSERT INTO @result VALUES(@date,-1)
            END
        FETCH next from cur into @date,@today_c,@today_MA,@today_bias,@trend
    END

    close cur
    DEALLOCATE cur 
    return
END