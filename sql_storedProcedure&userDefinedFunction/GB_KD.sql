ALTER FUNCTION GB_KD(
    @stock_code VARCHAR(10)
)
Returns @date_table TABLE(
    date date,
    Buy_sell INT
)
AS
BEGIN

    DECLARE @Buy_sell_table as TABLE(
        tmp_date date,
        tmp_Buy_sell INT
    )

    INSERT INTO @Buy_sell_table(tmp_date, tmp_Buy_sell) SELECT date, Buy_sell FROM dbo.GB_rule5(@stock_code)
    INSERT INTO @Buy_sell_table(tmp_date, tmp_Buy_sell) SELECT date, Buy_sell from dbo.GB_rule2_6(@stock_code, 3) 
                                                        where date not in (SELECT tmp_date from @Buy_sell_table)
    INSERT INTO @Buy_sell_table(tmp_date, tmp_Buy_sell) SELECT date, Buy_or_sell from dbo.GB_rule3_7(@stock_code, 2, 8, 3, 5, 3)
                                                        where date not in (SELECT tmp_date from @Buy_sell_table)
    INSERT INTO @Buy_sell_table(tmp_date, tmp_Buy_sell) SELECT date ,buy_or_sell from dbo.GB_rule4_8(@stock_code, 15, -10) 
                                                        where date not in (SELECT tmp_date from @Buy_sell_table)
    
    DECLARE cur CURSOR LOCAL FOR
        select tmp_date, tmp_Buy_sell from @Buy_sell_table order by tmp_date
    open cur

    DECLARE @date_tmp DATE
    DECLARE @Buy_sell_tmp INT

    FETCH NEXT from cur into @date_tmp, @Buy_sell_tmp

    WHILE @@FETCH_STATUS = 0 BEGIN

        DECLARE @type INT
        
        select @type = High_low from dbo.price_type_fun(@stock_code, 20, @date_tmp)

        IF @Buy_sell_tmp = 1 BEGIN

            IF @type = -1 BEGIN -- 代表在低檔而且符合GB買點
                INSERT INTO @date_table(date, Buy_sell) select @date_tmp, 2
            END
            ELSE IF @type = 0 BEGIN -- 代表不在低檔也不在高檔且符合GB買點
                INSERT INTO @date_table(date, Buy_sell) SELECT @date_tmp, 1
            END
        END -- 在高檔的買點我們不考慮操作
        ELSE IF @Buy_sell_tmp = -1 BEGIN

            IF @type = 1 BEGIN -- 代表在高檔且符合GB賣點
                INSERT INTO @date_table(date, Buy_sell) select @date_tmp, -2
            END
            ELSE IF @type = 0 BEGIN -- 代表不在低檔也不在高檔且符合GB賣點
                INSERT INTO @date_table(date, Buy_sell) select @date_tmp, -1
            END
        END -- 在低檔的賣點我們不考慮操作

        FETCH NEXT from cur into @date_tmp, @Buy_sell_tmp

    END
    CLOSE cur
    DEALLOCATE cur
    RETURN
END

