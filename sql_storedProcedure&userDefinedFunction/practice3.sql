ALTER PROCEDURE practice3
    @DATE date,
    @DAYS INT
AS
BEGIN

SELECT stock_code from(
    select stock_code,COUNT(*)CNT, STRING_AGG(date, '.') date, String_agg(d,',') d from dbo.股價資訊
    where exists(
        SELECT date FROM dbo.find_date(@DATE, @DAYS, 1, 0)
        where 股價資訊.date = date
    )and d >= 0
    group by stock_code
)result
where result.CNT = @DAYS
    




END
GO