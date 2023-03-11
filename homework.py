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



# Main Function
if __name__ == "__main__":
    
    # Enter the url of website

