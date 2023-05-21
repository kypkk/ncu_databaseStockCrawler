ALTER FUNCTION [dbo].[candlestick_type](
	@company varchar(10),
	@date varchar(10)
    )
RETURNS @result_table table (
        company VARCHAR(10),
        date VARCHAR(10),
        type INT
    )
AS
BEGIN
	DECLARE @type int;
	SET @type = 99

	DECLARE @stick_long float;
	DECLARE @stick_medium float;
	DECLARE @stick_short float;
	DECLARE @stick float;

	DECLARE @today_c float;
	DECLARE @yesterday_c float;
	DECLARE @today_o float;
	DECLARE @last_working_date date;
	--利用Candlestick_chart_def資料表定義長/中/小/極小紅黑的標準並取用
	SELECT @stick_long = value FROM Candlestick_chart_def WHERE state='long';
	SELECT @stick_medium = value FROM Candlestick_chart_def WHERE state='medium';
	SELECT @stick_short = value FROM Candlestick_chart_def WHERE state='short';
	--取得前一個工作日
    SELECT @last_working_date = date FROM find_last_date(@date);

	SELECT @today_c=c, @today_o=o FROM dbo.股價資訊 WHERE stock_code=@company and date = @date;
	SELECT @yesterday_c=c FROM dbo.股價資訊 WHERE stock_code=@company and date = @last_working_date;

	SET @stick = abs(@today_c - @today_o) / (@yesterday_c);
	IF @stick >= @stick_long SET @type=4;
	ELSE IF @stick < @stick_long and @stick >=@stick_medium SET @type=3;
	ELSE IF @stick < @stick_medium and @stick >=@stick_short SET @type=2;
	ELSE IF @stick < @stick_short and @stick > 0 SET @type=1;
	ELSE IF @stick=0 SET @type = 0;

	IF @today_c<@today_o SET @type=@type*-1

	INSERT INTO @result_table
    SELECT @company, @date, @type

    RETURN
END