ALTER function find_trend
(
    @stock_code VARCHAR(10)
)
RETURNS @result_table TABLE
(
    start_date date,
    start_price real,
    end_date date,
    end_price real,
    /* -1 short 0 nothing 1 long*/
    trend int
)
AS
BEGIN

    DECLARE @max_min_point as TABLE
    (
        date date not NULL,
        close_price real not null,
        max_min int
    )
    INSERT @max_min_point (date, close_price, max_min)
    SELECT date, close_price, max_min from dbo.find_max_min(@stock_code) order by date desc

    DECLARE @max_min_point_tmp as TABLE
    (
        /*新的極值價格與時間*/
        extremum_new real,
        date_new date,
        /*舊的極值價格與時間*/
        extremum_old real,
        date_old date,
        /* 0->min, 1->max */
        extremum_type int
    )

    INSERT INTO @max_min_point_tmp
    SELECT T1.close_price, T1.[date], T2.close_price, T2.[date], T1.max_min FROM @max_min_point AS T1
    CROSS APPLY(
        SELECT TOP 1 * FROM @max_min_point
        where max_min = T1.max_min AND date < T1.[date]
        order by date desc
    )T2

    INSERT @result_table 
    SELECT start_date, start_date_price, end_date, end_date_price, trend from(
        SELECT 
        T1.date_old as start_date,
        T1.extremum_old as start_date_price,
        T1.date_new as end_date,
        T1.extremum_new as end_date_price,
        case 
            when T1.extremum_new < T1.extremum_old and T2.extremum_new < T2.extremum_old THEN -1
            when T1.extremum_new > T1.extremum_old and T2.extremum_new > T2.extremum_old THEN 1
            else 0
        END as trend
        from @max_min_point_tmp as T1
        CROSS APPLY(
            SELECT TOP 1 * FROM @max_min_point_tmp
            where (date_new < T1.date_new and extremum_type != T1.extremum_new)
            order by date_new desc
        )T2
    )RESULT
    return

END