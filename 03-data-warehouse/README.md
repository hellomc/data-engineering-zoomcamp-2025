# HW3

## Environment Setup

Manually download parquet files *=[1, 6]

    wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-0*.parquet

Create an external table using the yellow taxi trip records

    CREATE OR REPLACE EXTERNAL TABLE `kestra-sandbox-449221.ny_taxi.external_yellow_tripdata`
    OPTIONS (
        format = 'PARQUET',
        uris = ['gs://dez_hw3_2025/yellow_tripdata_2024-*.parquet', 'gs://dez_hw3_2025/yellow_tripdata_2024-*.parquet']
    );

Run query to get 10 records

    SELECT * FROM kestra-sandbox-449221.ny_taxi.external_yellow_tripdata limit 10;

![text](/03-data-warehouse/img/Screenshot%202025-02-04%20at%202.38.50 PM.png)

Create a materialized table using the yellow taxi trip records from GCP Bucket

![text](/03-data-warehouse/img/Screenshot%202025-02-04%20at%2010.50.15 PM.png)

## Q1

Get number of records in 2024 Yellow Trip Data

    SELECT COUNT(*) FROM kestra-sandbox-449221.ny_taxi.external_yellow_tripdata

* 65,623
* 840,402
* 20,332,093
* 85,431,289

Answer 20332093

## Q2

Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

    SELECT COUNT(DISTINCT(PULocationID))
        FROM kestra-sandbox-449221.ny_taxi.external_yellow_tripdata;

    SELECT COUNT(DISTINCT(PULocationID))
        FROM kestra-sandbox-449221.ny_taxi.yellow_taxi_data;

* 18.82 MB for the External Table and 47.60 MB for the Materialized Table
* 0 MB for the External Table and 155.12 MB for the Materialized Table
* 2.14 GB for the External Table and 0MB for the Materialized Table
* 0 MB for the External Table and 0MB for the Materialized Table

Answer 0 MB for the External Table and 155.12 MB for the Materialized Table

## Q3

Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery.

    SELECT PULocationID
        FROM kestra-sandbox-449221.ny_taxi.yellow_taxi_data

Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?

    SELECT PULocationID, DOLocationID
        FROM kestra-sandbox-449221.ny_taxi.yellow_taxi_data

* BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.
* BigQuery duplicates data across multiple storage partitions, so selecting two columns instead of one requires scanning the table twice, doubling the estimated bytes processed.
* BigQuery automatically caches the first queried column, so adding a second column increases processing time but does not affect the estimated bytes scanned.
* When selecting multiple columns, BigQuery performs an implicit join operation between them, increasing the estimated bytes processed

Answer BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

## Q4

How many records have a fare amount of 0?

    SELECT COUNT(fare_amount)
        FROM kestra-sandbox-449221.ny_taxi.yellow_taxi_data
            WHERE fare_amount = 0.0;

* 128,210
* 546,578
* 20,188,016
* 8,333

Answer 8333

## Q5

What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_timedate and order the results by VendorID (Create a new table with this strategy)

    CREATE OR REPLACE TABLE kestra-sandbox-449221.ny_taxi.yellow_tripdata_partitioned2
        PARTITION BY DATE(tpep_pickup_datetime) AS
            CLUSTER BY VendorID AS
                SELECT * FROM kestra-sandbox-449221.ny_taxi.external_yellow_tripdata;

* Partition by tpep_dropoff_timedate and Cluster on VendorID
* Cluster on by tpep_dropoff_timedate and Cluster on VendorID
* Cluster on tpep_dropoff_timedate Partition by VendorID
* Partition by tpep_dropoff_timedate and Partition by VendorID

Answer Partition by tpep_dropoff_timedate and Cluster on VendorID

## Q6

Write a query to retrieve the distinct VendorIDs between tpep_dropoff_timedate 03/01/2024 and 03/15/2024 (inclusive)
Use the materialized table you created earlier in your from clause and note the estimated bytes.

    SELECT DISTINCT(VendorID)
        FROM kestra-sandbox-449221.ny_taxi.yellow_taxi_data
            WHERE DATE(tpep_dropoff_datetime) >= '2024-03-01' and DATE(tpep_dropoff_datetime) <= '2024-03-15';

Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?

    SELECT DISTINCT(VendorID)
        FROM kestra-sandbox-449221.ny_taxi.yellow_tripdata_partitioned2
            WHERE DATE(tpep_dropoff_datetime) >= '2024-03-01' and DATE(tpep_dropoff_datetime) <= '2024-03-15';

Choose the answer which most closely matches.

* 12.47 MB for non-partitioned table and 326.42 MB for the partitioned table
* 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table
* 5.87 MB for non-partitioned table and 0 MB for the partitioned table
* 310.31 MB for non-partitioned table and 285.64 MB for the partitioned table

Answer 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

## Q7

Where is the data stored in the External Table you created?

* Big Query
* Container Registry
* GCP Bucket
* Big Table

Answer GCP Bucket

## Q8

It is best practice in Big Query to always cluster your data:

* True
* False

Answer True

## Bonus Q8

No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

    SELECT COUNT(*)
        FROM kestra-sandbox-449221.ny_taxi.yellow_taxi_data;

Answer 0 bytes Why? Is it because the data is already cached in Big Query.
