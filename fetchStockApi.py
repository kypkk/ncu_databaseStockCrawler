import requests
import json
import time
import os
from dotenv import load_dotenv
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
        t = response['msgArray'][0]['t']
        o = response['msgArray'][0]['o']
        h = response['msgArray'][0]['h']
        l = response['msgArray'][0]['l']
        tv = int(float(response['msgArray'][0]['v']) * 1000)
        c = response['msgArray'][0]['z']
        d = float(response['msgArray'][0]['z']) - float(response['msgArray'][0]['y'])
        print(date, t, o, h, l, tv, c, d)
        # response = json.dumps(response, indent=4)
        # print(response)

        time.sleep(60)

# Main Function
if __name__ == "__main__":
    
    # Enter the url of website
    url = 'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0'
    crawl_stock_info(url)