import pandas as pd
import numpy as np

from pathlib import Path

import time
import logging
from functools import wraps

class InvalidOrderError(Exception):
    pass

SOURCE_DATA_DIR = Path(r'D:\PROJECTS\QuickKart_DarkStore\dataset')
DESTINATION_DATA_DIR = Path(r'D:\PROJECTS\QuickKart_DarkStore\cleaned_dataset')
DESTINATION_DATA_DIR.mkdir(parents=True, exist_ok=True)

tables = {
    'orders' : {
        'required_columns': ['order_id','customer_id','store_id','order_ts','rider_id','delivered_ts','promised_mins','status','payment_mode'], 
        'text_columns': ['order_id','customer_id','store_id', 'rider_id', 'status','payment_mode'], 
        'date_columns': ['order_ts','delivered_ts'], 
        'numerical_columns': ['promised_mins']
    },

    'order_items':{
        'required_columns': ['order_id', 'sku_id', 'qty', 'mrp', 'discount_pct', 'fulfilled_flag'],
        'text_columns': ['order_id', 'sku_id'],
        'date_columns': [],
        'numerical_columns': ['qty', 'mrp', 'discount_pct', 'fulfilled_flag']
    },

    'stores':{
        'required_columns': ['store_id', 'city', 'zone', 'opening_date', 'parent_hub_id'],
        'text_columns': ['store_id', 'city', 'zone', 'parent_hub_id'],
        'date_columns': ['opening_date'],
        'numerical_columns': []
    },

    'riders':{
        'required_columns': ['rider_id', 'store_id', 'join_date', 'shift', 'vehicle_type'],
        'text_columns': ['rider_id', 'store_id', 'shift', 'vehicle_type'],
        'date_columns': ['join_date'],
        'numerical_columns': []
    },

    'products':{
        'required_columns': ['sku_id', 'sku_name', 'category', 'sub_category', 'brand', 'mrp', 'shelf_life_days'],
        'text_columns': ['sku_id', 'sku_name', 'category', 'sub_category', 'brand'],
        'date_columns': [],
        'numerical_columns': ['mrp', 'shelf_life_days']
    },

    'daily_stock_snapshot':{
        'required_columns': ['snapshot_date', 'store_id', 'sku_id', 'closing_qty', 'received_qty'],
        'text_columns': ['store_id', 'sku_id'],
        'date_columns': ['snapshot_date'],
        'numerical_columns': ['closing_qty', 'received_qty']
    }
}


logging.basicConfig(
    filename="quickkart_pipeline.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    force=True
)

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()

        try:
            return func(*args, **kwargs)
        finally:
            end = time.perf_counter()
            print(f"{func.__name__} executed in {end-start:.4f} seconds")

    return wrapper

def log(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        logging.info(f"Started: {func.__name__}")

        try:
            result = func(*args, **kwargs)
            logging.info(f"Completed: {func.__name__}")
            return result

        except Exception:
            logging.exception(f"Failed: {func.__name__}")
            raise

    return wrapper

@timer
@log
def load_dataset(file_name):
    
    try:
        file_path = SOURCE_DATA_DIR/file_name
        df = pd.read_csv(file_path) 
        print(f"\n{file_name} loaded succssfully.")

        try:

            required_columns = tables[Path(file_name).stem]['required_columns']

            missing_columns = [col for col in required_columns if col not in df.columns]

            if missing_columns:
                raise InvalidOrderError(f"Missing columns: {missing_columns}")

            text_columns = tables[Path(file_name).stem]['text_columns']

            for col in text_columns:
                df[col] = df[col].str.strip().str.upper()
                df[col] = df[col].replace(['','NA', 'N/A', 'na', 'n/a'], np.nan)

            date_columns = tables[Path(file_name).stem]['date_columns']

            for col in date_columns:
                df[col] = pd.to_datetime(df[col])


            numerical_columns = tables[Path(file_name).stem]['numerical_columns']

            for col in numerical_columns:
                df[col] = pd.to_numeric(df[col])


            print("Cleaning completed.")
            have_duplicates = df.duplicated().sum()

            if have_duplicates != 0:
                print("Duplicates records :-",have_duplicates)
                df.drop_duplicates(inplace=True)

            df.to_csv(DESTINATION_DATA_DIR/file_name, index=False)

            return df

        except InvalidOrderError as e:
            print("Data validation error:", e)

        except Exception as e:
            print("Cleaning pipeline error:", e)

        return None
        
    except FileNotFoundError:
        print(f"Eror :- {file_name} not found.")
    
    except Exception as e:
        print(f"Errror :- {e}")
    
    return None

daily_stock_snapshot = load_dataset('daily_stock_snapshot.csv')
orders = load_dataset('orders.csv')
order_items = load_dataset('order_items.csv')
stores = load_dataset('stores.csv')
products = load_dataset('products.csv')
riders = load_dataset('riders.csv')

# Remove completely duplicate rows in the orders dataset
d_order_id = orders[orders['delivered_ts'] < orders['order_ts']]['order_id'].to_list()
orders.drop(orders[orders['delivered_ts'] < orders['order_ts']].index, inplace = True)

# Deduplicate order IDs by prioritizing rows with fewer missing values in payment_mode and delivered_ts
orders['null_count'] = orders[['payment_mode', 'delivered_ts']].isnull().sum(axis=1)
orders = orders.sort_values(by=['order_id', 'null_count'])
orders = orders.drop_duplicates(subset=['order_id'], keep='first')
orders = orders.drop(columns=['null_count'])
orders = orders.reset_index(drop=True)

# Identify order IDs that only contain items with 0 quantity (no valid products purchased)
delete_order_id = order_items.groupby('order_id').agg({'qty':'sum'}).query('qty == 0').index.tolist()

# Drop item rows where quantity is 0
order_items.drop(order_items[order_items['qty'] == 0].index, inplace=True)
order_items.drop(order_items[order_items['sku_id'] > 'SKU02500'].index, inplace=True)

# Remove orders from the main orders table that have no valid item quantities
orders.drop(orders[orders['order_id'].isin(delete_order_id)].index, inplace=True)
order_items.drop(order_items[order_items['order_id'].isin(d_order_id)].index, inplace=True)

orders.to_csv(DESTINATION_DATA_DIR/'orders.csv', index=False)
order_items.to_csv(DESTINATION_DATA_DIR/'order_items.csv', index=False)