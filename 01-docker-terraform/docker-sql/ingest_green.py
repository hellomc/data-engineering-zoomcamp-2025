from time import time
from sqlalchemy import create_engine
import pandas as pd
import argparse
import os

def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    tb = params.tb
    url = params.url
    csv_name = url.split("/")[-1]

    os.system(f"wget {url} -O {csv_name}")

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)

    df = next(df_iter)

    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

    df.head(n=0).to_sql(name=tb, con=engine, if_exists='replace')

    df.to_sql(name=tb, con=engine, if_exists='append')

    while True:
        t_start = time()
        
        df = next(df_iter)
        
        df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
        df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)
        
        df.to_sql(name=tb, con=engine, if_exists='append')
        
        t_end = time()
        
        print('inserted another chunk..., took %.3f seconds' % (t_end - t_start))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
                        description='Ingest CSV Data to Postgres')
    # user, pwd, host, port, db, tb, url
    parser.add_argument('--user', help='username for postgres')
    parser.add_argument('--password', help='password for postgres')
    parser.add_argument('--host', help='host for postgres')
    parser.add_argument('--port', help='port for postgres')
    parser.add_argument('--db', help='database name for postgres')
    parser.add_argument('--tb', help='table to write data to')
    parser.add_argument('--url', help='url of csv file')

    args = parser.parse_args()

    main(args)