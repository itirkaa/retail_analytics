# Retail Analytics Pipeline

This project implements a real-time retail analytics pipeline using Kafka, S3, Trino, and dbt. It processes user events and product metadata to generate valuable business insights.

## Project Structure
```
retail-pipeline/
├── docker-compose.yml          # Docker services configuration
├── data_generator/            
│   ├── requirements.txt        # Python dependencies for generator
│   └── generator.py           # Generates sample retail data
├── connectors/
│   └── s3-sink-connector.json # Kafka Connect S3 sink config
├── trino/
│   └── etc/
│       ├── config.properties  # Trino server config
│       ├── jvm.config        # JVM settings for Trino
│       └── catalog/
│           ├── iceberg.properties
│           └── hive.properties
└── dbt/
    ├── Dockerfile            # DBT environment setup
    ├── requirements.txt      # DBT dependencies
    ├── profiles.yml         # DBT connection profiles
    └── dbt_project.yml      # DBT project configuration
```

## Setup Instructions

### 1. Environment Setup
```bash
# Clone the repository
git clone https://github.com/your-org/retail-pipeline.git
cd retail-pipeline

# Start all services
docker-compose up -d
```

### 2. Configure Kafka Connect
```bash
# Create the S3 sink connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/s3-sink-connector.json
```

### 3. Start Data Generation
```bash
# Install dependencies
cd data_generator
pip install -r requirements.txt

# Start generator
python generator.py
```

### 4. Setup DBT
```bash
# Build DBT container
cd dbt
docker build -t retail-dbt .

# Run initial models
docker run --network retail-pipeline_default retail-dbt run
```

### 5. Setup Cron Jobs for DBT
Create a crontab entry:
```bash
# Edit crontab
crontab -e

# Add these entries:

# Run staging models every hour
0 * * * * docker run --network retail-pipeline_default retail-dbt run --select staging

# Run mart models every 3 hours
0 */3 * * * docker run --network retail-pipeline_default retail-dbt run --select marts

# Run all tests daily
0 0 * * * docker run --network retail-pipeline_default retail-dbt test

# Generate docs weekly
0 0 * * 0 docker run --network retail-pipeline_default retail-dbt docs generate
```

## Available Data Models

### Staging Models
- `stg_product_metadata`: Cleaned product catalog data
- `stg_user_events`: Processed user interaction events

### Mart Models
- `product_category_revenue`: Revenue analysis by category
- `top_viewed_products`: Most viewed products
- `same_day_purchasers`: Users with multiple same-day purchases

