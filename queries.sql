
use Flight_Analysis;
select * from airlines;
select * from airports;
select * from city;
select * from flight_data_2024;
select *  from flight_details;
select * from flights;

INSERT INTO airlines (carrier_code)
SELECT DISTINCT op_unique_carrier
FROM flight_data_2024
WHERE op_unique_carrier IS NOT NULL;
 select * from airlines;
 
 INSERT INTO city (city_name, state_name)
SELECT DISTINCT origin_city_name, origin_state_nm
FROM flight_data_2024
UNION
SELECT DISTINCT dest_city_name, dest_state_nm
FROM flight_data_2024;
select * from city;

INSERT INTO airports (airport_code, city_id)
SELECT DISTINCT f.origin , c.city_id
FROM flight_data_2024 f
JOIN city c 
ON f.origin_city_name = c.city_name 
AND f.origin_state_nm = c.state_name;

 select * from airports;
 
 INSERT INTO flights (
    carrier_code,
    flight_number,
    origin_airport,
    destination_airport,
    flight_date,
    distance
)
SELECT 
    op_unique_carrier,
    op_carrier_fl_num,
    origin,
    dest,
    fl_date,
    distance
FROM flight_data_2024;
select * from flights;

INSERT INTO flight_details (
    flight_id,
    year,
    month,
    day_of_month,
    day_of_week,
    crs_dep_time,
    dep_time,
    dep_delay,
    taxi_out,
    wheels_off,
    wheels_on,
    taxi_in,
    crs_arr_time,
    arr_time,
    arr_delay,
    cancelled,
    cancellation_code,
    diverted,
    air_time,
    carrier_delay,
    weather_delay,
    nas_delay,
    security_delay,
    late_aircraft_delay
)
SELECT 
    f.flight_id,
    fd.year,
    fd.month,
    fd.day_of_month,
    fd.day_of_week,
    fd.crs_dep_time,
    fd.dep_time,
    fd.dep_delay,
    fd.taxi_out,
    fd.wheels_off,
    fd.wheels_on,
    fd.taxi_in,
    fd.crs_arr_time,
    fd.arr_time,
    fd.arr_delay,
    fd.cancelled,
    fd.cancellation_code,
    fd.diverted,
    fd.air_time,
    fd.carrier_delay,
    fd.weather_delay,
    fd.nas_delay,
    fd.security_delay,
    fd.late_aircraft_delay
FROM flight_data_2024 fd
JOIN flights f 
ON fd.op_carrier_fl_num = f.flight_number;

select * from flight_details;
select * from flight_data_2024;
INSERT INTO flights (
    carrier_code,
    flight_number,
    origin_airport,
    destination_airport,
    flight_date,
    distance
)
SELECT 
    op_unique_carrier,
    op_carrier_fl_num,
    origin,
    dest,
    fl_date,
    distance
FROM flight_data_2024;

INSERT INTO flight_details (
    flight_id,
    year,
    month,
    day_of_month,
    day_of_week,
    crs_dep_time,
    dep_time,
    dep_delay
)
SELECT 
    f.flight_id,
    fd.year,
    fd.month,
    fd.day_of_month,
    fd.day_of_week,
    fd.crs_dep_time,
    fd.dep_time,
    fd.dep_delay
FROM flight_data_2024 fd
JOIN flights f 
ON fd.op_carrier_fl_num = f.flight_number;

## TOTAL FLIGHT PER ROUTE

SELECT 
    origin,
    origin_city_name,
    origin_state_nm,
    dest,
    dest_city_name,
    dest_state_nm,
    COUNT(*) AS total_flights
FROM flight_data_2024
GROUP BY 
    origin,
    origin_city_name,
    origin_state_nm,
    dest,
    dest_city_name,
    dest_state_nm
ORDER BY total_flights DESC
LIMIT 10;
select * from flight_data_2024;

##AVERAGE DELAY PER ROUTE

SELECT 
origin_city_name ,origin_state_nm  ,
dest_city_name,  dest_state_nm,
AVG(dep_delay) AS avg_departure_delay,
AVG(arr_delay) AS avg_arrival_delay
FROM flight_data_2024
GROUP BY origin_city_name ,origin_state_nm,
dest_city_name,  dest_state_nm
ORDER BY avg_departure_delay DESC
LIMIT 10;

## DISTANCE VS ROUTE ANALYSIS

SELECT 
origin,origin_city_name,origin_state_nm,
dest,dest_city_name,dest_state_nm,
AVG(distance) AS avg_distance,
COUNT(*) AS total_flights
FROM flight_data_2024
GROUP BY origin,origin_city_name,origin_state_nm,
dest,dest_city_name,dest_state_nm
ORDER BY avg_distance DESC
LIMIT 5;

## TOP AIRLINES PER ROUTE

SELECT 
origin_state_nm,
dest_state_nm,
op_unique_carrier,
COUNT(*) AS flights_count
FROM flight_data_2024
GROUP BY origin_state_nm, dest_state_nm, op_unique_carrier
ORDER BY flights_count DESC
limit 10;

## CANCELLED FLIGHTS PER ROUTE
SELECT 
origin_city_name,
dest_city_name,
COUNT(*) AS cancelled_flights
FROM flight_data_2024
WHERE cancelled = 1
GROUP BY origin_city_name, dest_city_name
ORDER BY cancelled_flights DESC;

 ##TOP RPUTES + AVERAGE DELAY(CORELATION)
## Which busy routes also have high delays?
SELECT 
origin_city_name,
dest_city_name,
COUNT(*) AS total_flights,
AVG(dep_delay) AS avg_dep_delay,
AVG(arr_delay) AS avg_arr_delay
FROM flight_data_2024
GROUP BY origin_city_name, dest_city_name
HAVING COUNT(*) > 100
ORDER BY avg_dep_delay DESC;

## ROUTE PERFORMANCE CLASSIFICATION

SELECT 
origin,
dest,
COUNT(*) AS total_flights,
SUM(CASE WHEN dep_delay <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS on_time_percentage
FROM flight_data_2024
GROUP BY origin, dest
ORDER BY on_time_percentage ASC
LIMIT 10;

##  BEST AIRLINE FOR EACH ROUTE 
SELECT 
origin_city_name,
dest_city_name,
op_unique_carrier,
AVG(arr_delay) AS avg_arr_delay
FROM flight_data_2024
GROUP BY origin_city_name, dest_city_name, op_unique_carrier
ORDER BY origin_city_name, dest_city_name, avg_arr_delay;


##MOST PROBLEMATIC ROUTES(DELAYS + CANCELLATIONS)
SELECT 
origin,
dest,
COUNT(*) AS total_flights,
SUM(cancelled) AS total_cancelled,
AVG(dep_delay) AS avg_delay
FROM flight_data_2024
GROUP BY origin, dest
HAVING total_cancelled > 10
ORDER BY avg_delay DESC;

## DISTACE VS DELAY RELATIONSHIP
SELECT 
origin,
dest,
AVG(distance) AS avg_distance,
AVG(dep_delay) AS avg_delay
FROM flight_data_2024
GROUP BY origin, dest
ORDER BY avg_distance DESC;

## PEAK MONTH ROUTES
SELECT 
month,
origin_city_name,
dest_city_name,
COUNT(*) AS total_flights
FROM flight_data_2024
GROUP BY month, origin_city_name, dest_city_name
ORDER BY month, total_flights DESC
LIMIT 5;

## ROUTES WITH WORST WEATHER IMPACT
SELECT 
origin_city_name,
dest_city_name,
AVG(weather_delay) AS avg_weather_delay
FROM flight_data_2024
GROUP BY origin_city_name, dest_city_name
ORDER BY avg_weather_delay DESC
LIMIT 5;

select * from city
order by state_name;