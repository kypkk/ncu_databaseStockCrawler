import pymssql
import pandas as pd
import os
import numpy as np
import mplfinance as mpf
from collections import defaultdict
from dotenv import load_dotenv

load_dotenv()

db_Password = os.getenv('PASSWORD')


def connect_SQL_server():
    db_settings = {
        "host": "localhost",
        "user": "sa",
        "password": db_Password,
        "database": "TutorialDB",
        "charset": "utf8"
    }

    conn  = pymssql.connect(**db_settings)
    return conn

def get_data(company, start, end, cursor):

    command = f"""SELECT [date],[o],[h],[l],[c],[v],[MA5],[MA10]
            FROM [dbo].[股價資訊] 
            where [stock_code] = {company} AND date > '{start}' AND date < '{end}'"""
    cursor.execute(command)

    arr = []
    row = cursor.fetchone()  
    while row:
        arr.append(row)
        row = cursor.fetchone()
    
    arr_df = pd.DataFrame(arr)
    arr_df['Date'] = pd.to_datetime(arr_df[0])
    arr_df = arr_df.sort_values(by="Date")
    arr_df = arr_df.drop(columns=[0]) # remove extra date column
    arr_df.set_index("Date",inplace=True)
    
    arr_df.columns = ['Open', 'High', 'Low', 'Close', 'Volume','MA5','MA10']

    return arr_df

def get_turning_wave(company, start, end, cursor):
    command = f"""select end_date, end_price, trend
            from find_trend('{company}')
            where end_date > '{start}' and end_date < '{end}'
            order by end_date asc
          """
    cursor.execute(command)

    arr = []
    row = cursor.fetchone()  
    while row:
        arr.append(row)
        row = cursor.fetchone()
    
    df = pd.DataFrame(arr)
    df.columns = ['date', 'close_price', 'trend']
    df.loc[:, 'date'] = pd.to_datetime(df['date'])
    
    # 開始找轉折點 -> 從日期最大的找起
    df_result = pd.DataFrame()

    # 先取得第一個趨勢
    cur_trend = 0
    for idx in range(df['date'].size - 1, 0, -1):
        if df.loc[idx, 'trend'] != 0:
            cur_trend = df.loc[idx, 'trend']
            break

    cur_max_min = 0 # 根據當前趨勢，去暫存最大或最小收盤價 
    cur_start_day = np.nan
    for idx in range(df['date'].size - 1, -1, -1):
        # 趨勢轉變 跟 最後一筆時, 儲存資訊
        if (df.loc[idx, 'trend'] != 0 and df.loc[idx, 'trend'] != cur_trend) or idx == 0:
            # save
            df_tmp = pd.DataFrame([[cur_start_day, np.nan, cur_max_min, cur_trend]],
                   columns=['start_day', 'end_day', 'close_price', 'trend'])
            df_result = pd.concat([df_tmp, df_result])
            
            # reset
            cur_trend = df.loc[idx, 'trend']
            cur_max_min = 0
        
        if cur_trend == 1: # find max
            if df.loc[idx, 'close_price'] > cur_max_min:
                cur_max_min = df.loc[idx, 'close_price']
                cur_start_day = df.loc[idx, 'date']
        else: # cur_tend == -1, find min
            if df.loc[idx, 'close_price'] < cur_max_min or cur_max_min == 0:
                cur_max_min = df.loc[idx, 'close_price']
                cur_start_day = df.loc[idx, 'date']
    
    # reset index because the indices would all be zeros
    df_result.reset_index(drop=True, inplace=True)
    
    # 新增 end day
    df_result['end_day'] = df_result['start_day'].shift()
    # 因為第0筆沒有資料，直接放入最舊的日期
    df_result.loc[0, 'end_day'] = df.loc[0, 'date']
    
    return df_result

conn = connect_SQL_server()
cursor = conn.cursor()

company = '2330'
day_start = '20210101'
day_end = '20220228'
df = get_data(company, day_start, day_end, cursor)

turning_wave = get_turning_wave(company, day_start, day_end, cursor)

datepairs_turning_wave = [(d1, d2) for d1, d2 in zip(turning_wave['end_day'], turning_wave['start_day'])]

print(datepairs_turning_wave)

mpf.plot(df, type='candle', style='yahoo', mav = (5), volume = True, figsize=(100,30),
                 tlines = [dict(tlines=datepairs_turning_wave, tline_use='close', colors='b', linewidths=5, alpha=0.7)])
mpf.show