
select d, string_agg(name, ',')name, day_of_stock from dbo.股價資訊
join dbo.行事曆 on dbo.股價資訊.date = dbo.行事曆.date
join dbo.股票資訊 on dbo.股票資訊.stock_code = dbo.股價資訊.stock_code
where d > -1 and d < 1 and dbo.股價資訊.date = '2022-01-18'
group by d, day_of_stock


