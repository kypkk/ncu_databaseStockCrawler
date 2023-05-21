Declare @date date 
Declare @id varchar(10)
SELECT @date=max(date) from dbo.股價資訊

DECLARE @stock_code varchar(10)
set @stock_code = '2330'
DECLARE @i INT
DECLARE @K_val real 
DECLARE @D_val real 
DECLARE @K_preval real 
DECLARE @D_preval real 


-- CREATE TABLE #stock_temp(
--     id int IDENTITY(1,1),
--     date date not null,
--     stock_code varchar(10) not null,
--     K_va real not null,
--     D_va real not null
-- )

CREATE TABLE #result_1(
    stock_code varchar(10),
    date date,
    result varchar(50),
    yesterday_k real,
    yesterday_d real,
    today_k real,
    today_d real
)

    DELETE from #stock_temp
    DELETE from #result_1
    INSERT #stock_temp Select date, stock_code, K_value, D_value from dbo.股價資訊 where stock_code = @stock_code order by date
    -- select * from #stock_temp
    SELECT TOP(1) @i = id, @K_preval = K_va, @D_preval = D_va from #stock_temp

    DELETE #stock_temp where id = @i
    WHILE EXISTS(SELECT * from #stock_temp)
        BEGIN
            SELECT TOP(1) @date = date, @i = id, @stock_code = stock_code, @K_val = K_va, @D_val = D_va from #stock_temp
            if(@K_preval < @D_preval and @K_val > @D_val)
                INSERT into #result_1(stock_code, date, result, yesterday_k, yesterday_d, today_k, today_d) VALUEs(@stock_code, @date, 'huangjinjiaocha', @K_preval, @D_preval, @K_val, @D_val)
            else if(@K_preval > @D_preval and @K_val < @D_val)
                INSERT into #result_1(stock_code, date, result, yesterday_k, yesterday_d, today_k, today_d) VALUEs(@stock_code, @date, 'siwangjiaocha', @K_preval, @D_preval, @K_val, @D_val)
            set @K_preval = @K_val
            set @D_preval = @D_val
            print(@date)
            DELETE #stock_temp where id = @i
        END
SELECT * from #result_1