CREATE TABLE hive.default.user_events (
     event_type VARCHAR,
     user_id INT,
     product_id INT,
     amount DOUBLE,
     stock INT,
     timestamp TIMESTAMP
 ) WITH (
     external_location = 's3://retail-data/raw-data/product-metadata',
     format = 'JSON'
 );

