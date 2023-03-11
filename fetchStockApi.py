import requests
import json
import time
import os
import pymssql
import concurrent.futures
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

    while True:
        response = requests.get(url).text
        response = json.loads(response)
        # print(response['msgArray'])
        date = response['msgArray'][0]['d']
        timeToInsert = response['msgArray'][0]['t']
        stock_code = response['msgArray'][0]['c']
        o = float(response['msgArray'][0]['o'])
        h = float(response['msgArray'][0]['h'])
        l = float(response['msgArray'][0]['l'])
        tv = int(float(response['msgArray'][0]['v']) * 1000)
        c = float(response['msgArray'][0]['z'])
        d = float(response['msgArray'][0]['z']) - float(response['msgArray'][0]['y'])
        print(date, timeToInsert, o, h, l, tv, c, d)
        response = json.dumps(response, indent=4)
        # print(response)

        try:
            conn = pymssql.connect(**db_settings)
            command = "INSERT INTO [dbo].[股價資訊] (stock_code, date, time, tv, t, o, h, l, c, d, v, MA5, MA10, MA20, MA60, MA120, MA240) VALUES (%s, %s, %s, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)"
            with conn.cursor() as cursor:
                cursor.execute(command, (stock_code, date, timeToInsert, tv,0, o, h, l, c, d, 0, 0, 0, 0, 0, 0, 0))
                conn.commit()
        except Exception as e:
            print(e)    
        time.sleep(60)

# Main Function
if __name__ == "__main__":
    
    # Enter the url of website
    url_2330 = 'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0'
    url_0050 = 'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_0050.tw&json=1&delay=0'

    with ThreadPoolExecutor() as executor:  
        executor.map(crawl_stock_info,[url_2330, url_0050]) 
