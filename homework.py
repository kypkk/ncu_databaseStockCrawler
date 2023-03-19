import requests
import json
import time
import os
import pymssql
import concurrent.futures
from fake_useragent import UserAgent
from concurrent.futures import ThreadPoolExecutor
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

db_Password = os.getenv('PASSWORD')
db_settings = {
    "host": "127.0.0.1",
    "user": "SA",
    "password": db_Password,
    "database": "TutorialDB",
    "charset": "utf8"
}

def crawl_stock_info(url):
    user_agent = UserAgent()
    response = requests.get(url=url, headers={ 'user-agent': user_agent.random }).text
    response = json.loads(response)
    stock_code = url.split("=")[-1]
    hint_date = url.split("=")[-2].split("&")[0]
    for data in response["data"]:
        [date, tv, t, o, h, l, c, d, v] = data #拿資料
        # 處理資料型態
        date = date.split("/")
        date = str(1911 + int(date[0])) + date[1] + date[2]
        tv = int(tv.replace(",", ""))
        t = int(t.replace(",", ""))
        o = float(0.0 if o.replace(',', '') == '--' else o.replace(',', ''))
        h = float(0.0 if h.replace(',', '') == '--' else h.replace(',', ''))
        l = float(0.0 if l.replace(',', '') == '--' else l.replace(',', ''))
        c = float(0.0 if c.replace(',', '') == '--' else c.replace(',', ''))
        d = float(0.0 if d.replace(',', '') == '--' else d.replace(',', ''))
        v = float(0.0 if v.replace(',', '') == '--' else v.replace(',', ''))
        # print(date, stock_code)

        # Insert 進入資料庫
        try:
            conn = pymssql.connect(**db_settings)
            command = "INSERT INTO [dbo].[股價資訊](stock_code, date, tv, t, o, h, l, c, d, v) VALUES (%s, %s, %d, %d, %s, %s, %s, %s, %s, %s)"
            with conn.cursor() as cursor:
                cursor.execute(command, (stock_code, date, tv, t, o, h, l, c, d, v))
                conn.commit()
                  
        except Exception as e:
            print(e)    
    # time.sleep(20)
    # hint
    print(f"----------Insertion Successfully---------- date: {hint_date} code: {stock_code}")
    
    time.sleep(20)


# Main Function
if __name__ == "__main__":
    urls = []
    taiwan50 = [2881, 2882, 2891, 1303, 2303, 2308, 2317, 2330, 2412, 2454]
    # Enter the url of website
    # for code in taiwan50:
    #     for year in range (2021, 2023):
    #         for month in range(1, 13):
    #             date = str(year)+f"{month:02d}"+"01"
    #             url = f'https://www.twse.com.tw/exchangeReport/STOCK_DAY?re%20sponse=json&date={date}&stockNo={code}'
    #             urls.append(url)
    for code in taiwan50:
        for month in range(1,4):
            date = "2023"+f"{month:02d}"+"01"
            url = f'https://www.twse.com.tw/exchangeReport/STOCK_DAY?re%20sponse=json&date={date}&stockNo={code}'
            urls.append(url)
            # print(url)
    # print(urls)
    with ThreadPoolExecutor(max_workers=5) as executor:  
        executor.map(crawl_stock_info, urls) 