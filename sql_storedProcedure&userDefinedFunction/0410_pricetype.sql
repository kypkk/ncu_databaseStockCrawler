ALTER PROCEDURE dbo.price_type
    @company_input VARCHAR(10),
    @settings_days INT,
    @setting_date DATE,
    @type INT OUTPUT
AS
BEGIN

SET NOCOUNT ON;
DECLARE @sqltext VARCHAR(1000);
CREATE TABLE #stock_temp(
    company_temp VARCHAR(10),
    date_temp DATE,
    h_temp BIGINT,
)

DECLARE @IsWorkingDay INT
DECLARE @High_def FLOAT
DECLARE @Low_def FLOAT
SET @type = 99;

SELECT @IsWorkingDay = day_of_stock from dbo.行事曆 where date = @setting_date;
IF(@IsWorkingDay = -1) RETURN;

SELECT @High_def = high, @Low_def = low from dbo.price_high_low WHERE compare_with = @settings_days

SET @sqltext = N'select top(' + CAST(@settings_days as varchar) + ') stock_code, date, h from dbo.股價資訊 where stock_code = ' + @company_input + ' AND date <= ''' + CAST(@setting_date as varchar) + '''order by date desc'
INSERT INTO #stock_temp(company_temp, date_temp, h_temp) EXEC (@sqltext)

SELECT * from #stock_temp
DECLARE @temp INT
SELECT @temp = ROWID from
(SELECT ROW_NUMBER() OVER(ORDER BY h_temp desc) AS  ROWID,*from #stock_temp) T1
where T1.date_temp = @setting_date

if(@temp <= @settings_days*@High_def)
    set @type = 1;
else if(@temp >= @settings_days - (@settings_days*@Low_def))
    set @type = -1
ELSE
    set @type = 0

END