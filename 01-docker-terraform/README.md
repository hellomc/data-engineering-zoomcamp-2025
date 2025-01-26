# Homework 1

## Q1

Used the following Dockerfile

    FROM python:3.12.8

    ENTRYPOINT ["bash"]

Used command

    pip --version

Answer 24.3.1

## Q2

Based on the following Dockerfile what is the hostname and port that pgadmin should use to connect to the postgres database?

    services:
        db:
            container_name: postgres
            image: postgres:17-alpine
            environment:
            POSTGRES_USER: 'postgres'
            POSTGRES_PASSWORD: 'postgres'
            POSTGRES_DB: 'ny_taxi'
            ports:
            - '5433:5432'
            volumes:
            - vol-pgdata:/var/lib/postgresql/data

        pgadmin:
            container_name: pgadmin
            image: dpage/pgadmin4:latest
            environment:
            PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
            PGADMIN_DEFAULT_PASSWORD: "pgadmin"
            ports:
            - "8080:80"
            volumes:
            - vol-pgadmin_data:/var/lib/pgadmin  

    volumes:
        vol-pgdata:
            name: vol-pgdata
        vol-pgadmin_data:
            name: vol-pgadmin_data

Answer db:5433

## Q3

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:

Up to 1 mile

    SELECT
        COUNT(trip_distance)
        FROM green_taxi_data
            WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                AND trip_distance <= 1.0;

Answer 104802

In between 1 (exclusive) and 3 miles (inclusive)

    SELECT
        COUNT(trip_distance)
        FROM green_taxi_data
            WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                AND trip_distance > 1.0 AND trip_distance <= 3.0;

Answer 198924

In between 3 (exclusive) and 7 miles (inclusive)

    SELECT
        COUNT(trip_distance)
        FROM green_taxi_data
            WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                AND trip_distance > 3.0 AND trip_distance <= 7.0;

Answer 109603

In between 7 (exclusive) and 10 miles (inclusive)

    SELECT
        COUNT(trip_distance)
        FROM green_taxi_data
            WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                AND trip_distance > 7.0 AND trip_distance <= 10.0;

Answer 27678

Over 10 miles

    SELECT
        COUNT(trip_distance)
        FROM green_taxi_data
            WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                AND trip_distance > 10.0;

Answer 35189

Answer 104,802; 198,924; 109,603; 27,678; 35,189

## Q4

Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance.

2019-10-11
2019-10-24
2019-10-26
2019-10-31

    SELECT
        DATE(lpep_pickup_datetime),
        max(trip_distance)
        FROM green_taxi_data
            WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                GROUP BY DATE(lpep_pickup_datetime)
                    ORDER BY max(trip_distance) DESC
                        LIMIT 1;

Answer 2019-10-11

## Q5

Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?

Consider only lpep_pickup_datetime when filtering by date.

East Harlem North, East Harlem South, Morningside Heights
East Harlem North, Morningside Heights
Morningside Heights, Astoria Park, East Harlem South
Bedford, East Harlem North, Astoria Park

    SELECT
        green_taxi_data."PULocationID",
        zones."Zone",
        SUM(green_taxi_data.total_amount)
        FROM green_taxi_data
            LEFT JOIN zones ON green_taxi_data."PULocationID" = zones."LocationID"
                WHERE DATE(lpep_pickup_datetime) = '2019-10-18'
                    GROUP BY green_taxi_data."PULocationID", zones."Zone"
                        ORDER BY SUM(green_taxi_data.total_amount) DESC
                            LIMIT 3;

Answer East Harlem North, East Harlem South, Morningside Heights

## Q6

Question 6. Largest tip

For the passengers picked up in October 2019 in the zone named "East Harlem North" which was the drop off zone that had the largest tip?

Note: it's tip , not trip

We need the name of the zone, not the ID.

Yorkville West
JFK Airport
East Harlem North
East Harlem South

    SELECT
        green_taxi_data."PULocationID",
        zones."Zone",
        max(green_taxi_data.tip_amount),
        green_taxi_data."DOLocationID"
        FROM green_taxi_data
            LEFT JOIN zones ON green_taxi_data."PULocationID" = zones."LocationID"
                WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
                    AND DATE(lpep_dropoff_datetime) >= '2019-10-01' AND DATE(lpep_dropoff_datetime) < '2019-11-01'
                    AND zones."Zone" = 'East Harlem North'
                    GROUP BY green_taxi_data."PULocationID", green_taxi_data."DOLocationID", zones."Zone"
                        ORDER BY max(green_taxi_data.tip_amount) DESC
                            LIMIT 1;

This SQL query returned
PULocationID 74
Zone East Harlem North
max 87.3
DOLocationID 132

I looked up 132 in the table for zones.

Answer JFK Airport

## Q7

Question 7. Terraform Workflow

Which of the following sequences, respectively, describes the workflow for:

Downloading the provider plugins and setting up backend,
Generating proposed changes and auto-executing the plan
Remove all resources managed by terraform`
Answers:

terraform import, terraform apply -y, terraform destroy
teraform init, terraform plan -auto-apply, terraform rm
terraform init, terraform run -auto-approve, terraform destroy
terraform init, terraform apply -auto-approve, terraform destroy
terraform import, terraform apply -y, terraform rm

Answer terraform init, terraform apply -auto-approve, terraform destroy