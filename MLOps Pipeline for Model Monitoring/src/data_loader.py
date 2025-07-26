# data loading and preprocessing for MLOps pipeline
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os

class DataLoader:
    
    def __init__(self, data_path="data/raw/"):
        self.data_path = data_path
        
    def load_housing_data(self):
        # load california housing dataset
        from sklearn.datasets import fetch_california_housing
        
        housing = fetch_california_housing(as_frame=True)
        df = housing.frame
        
        # add some extra features to make it more realistic
        np.random.seed(42)
        df['property_age'] = np.random.randint(1, 50, len(df))
        df['neighborhood_score'] = np.random.uniform(1, 10, len(df))
        
        return df
    
    def add_timestamps(self, df, start_date="2023-01-01"):
        # add timestamp column to simulate real-world data streaming
        start = pd.to_datetime(start_date)
        
        # create timestamps over several months
        timestamps = pd.date_range(
            start=start, 
            periods=len(df), 
            freq='H'
        )
        
        df = df.copy()
        df['timestamp'] = timestamps
        df['date'] = df['timestamp'].dt.date
        
        return df
    
    def split_by_time(self, df, split_date):
        # split data by timestamp for temporal validation
        split_dt = pd.to_datetime(split_date)
        
        train_data = df[df['timestamp'] < split_dt].copy()
        test_data = df[df['timestamp'] >= split_dt].copy()
        
        return train_data, test_data
    
    def save_processed_data(self, df, filename, output_dir="data/processed/"):
        # save processed data to file
        os.makedirs(output_dir, exist_ok=True)
        filepath = os.path.join(output_dir, filename)
        df.to_csv(filepath, index=False)
        print(f"Data saved to {filepath}")
        
    def create_daily_batches(self, df, output_dir="data/processed/"):
        # create daily data batches for monitoring simulation
        os.makedirs(output_dir, exist_ok=True)
        
        # group by date and save each day's data
        for date, group in df.groupby('date'):
            filename = f"day_{date.strftime('%Y_%m_%d')}.csv"
            filepath = os.path.join(output_dir, filename)
            group.to_csv(filepath, index=False)
            
        print(f"Created {len(df.groupby('date'))} daily batch files in {output_dir}")
