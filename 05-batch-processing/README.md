# HW5

## Misc Notes

Refer to hw5.ipynb

Before Running Jupyter Notebook, run these commands, to run spark on python

```python
export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH"
```

Check localhost:4040 for Spark jobs

Using Yellow Taxi Data from October 2024

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-10.parquet
```

## Q1 Install Spark and PySpark

- Install Spark
- Run PySpark
- Create a local spark session
- Execute spark.version.

What's the output?

Answer 3.5.5

## Q2 Yellow October 2024

Read the October 2024 Yellow into a Spark Dataframe.

Repartition the Dataframe to 4 partitions and save it to parquet.

What is the average size of the Parquet (ending with .parquet extension) Files that were created (in MB)? Select the answer which most closely matches.

- 6MB
- 25MB
- 75MB
- 100MB

Answer 25 MB (24 MB)

## Q3 Count records

```spark
from pyspark.sql import functions as F

df_pickup_oct_15 = df_yellow_oct_2024.select("tpep_pickup_datetime") \
    .filter(F.to_date(df_yellow_oct_2024.tpep_pickup_datetime) == "2024-10-15")

df_pickup_oct_15.count()
```

How many taxi trips were there on the 15th of October?

Consider only trips that started on the 15th of October.

- 85,567
- 105,567
- 125,567
- 145,567

Answer 125,567 (128,909)

## Q4 Longest trip

```spark
df_trip_duration = spark.sql("""
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    TIMESTAMPDIFF(HOUR, tpep_pickup_datetime, tpep_dropoff_datetime) as trip_duration
FROM
    yellow
ORDER BY
    trip_duration DESC
LIMIT 1
""")

df_trip_duration.show()
```

What is the length of the longest trip in the dataset in hours?

- 122
- 142
- 162
- 182

Answer 162

## Q5 User Interface

Spark’s User Interface which shows the application's dashboard runs on which local port?

- 80
- 443
- 4040
- 8080

Answer 4040

## Q6 Least frequent pickup location zone

```spark
df_zones = spark.read.parquet('zones/')
df_zones.createOrReplaceTempView('zonelookup')
df_yellow_oct_2024.createOrReplaceTempView('yellowtaxi')

df_least_freq_zone = spark.sql("""
SELECT
    z.zone,
    COUNT (y.PULocationID) as pickup_count
FROM zonelookup z
JOIN yellowtaxi y ON y.PULocationID = z.LocationID
GROUP BY z.zone
ORDER BY pickup_count ASC
LIMIT 1
""")

df_least_freq_zone.show()
```

Load the zone lookup data into a temp view in Spark:

```bash
wget https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv
```

Using the zone lookup data and the Yellow October 2024 data, what is the name of the LEAST frequent pickup location Zone?

- Governor's Island/Ellis Island/Liberty Island
- Arden Heights
- Rikers Island
- Jamaica Bay

Answer Governor's Island/Ellis Island/Liberty Island
