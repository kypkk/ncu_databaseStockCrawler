CREATE FUNCTION price_type_fun(
    @company_input VARCHAR(10),
    @settings_days INT,
    @setting_date DATE
)
Returns @price_type TABLE(
    High_low INT
)
AS
BEGIN


DECLARE @stock_temp as TABLE(
    company_temp VARCHAR(10),
    date_temp DATE,
    h_temp BIGINT
)

DECLARE @IsWorkingDay INT
DECLARE @High_def FLOAT
DECLARE @Low_def FLOAT
DECLARE @type INT

SET @type = 99

SELECT @IsWorkingDay = day_of_stock from dbo.行事曆 where date = @setting_date;
IF(@IsWorkingDay = -1) RETURN;

SELECT @High_def = high, @Low_def = low from dbo.price_high_low WHERE compare_with = @settings_days

INSERT INTO @stock_temp(company_temp, date_temp, h_temp) SELECT top(@settings_days) stock_code, date, h from dbo.股價資訊 where stock_code = @company_input and date <= @setting_date order by date desc


DECLARE @temp INT
SELECT @temp = ROWID from
(SELECT ROW_NUMBER() OVER(ORDER BY h_temp desc) AS  ROWID,*from @stock_temp) T1
where T1.date_temp = @setting_date

if(@temp <= @settings_days*@High_def)
    set @type = 1;
else if(@temp >= @settings_days - (@settings_days*@Low_def))
    set @type = -1
ELSE
    set @type = 0
INSERT into @price_type(High_low) select @type

return

END