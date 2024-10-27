# dbt/Dockerfile
FROM python:3.9-slim

WORKDIR /usr/app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y git build-essential

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy dbt project
COPY . .

# Keep container running
CMD ["tail", "-f", "/dev/null"]