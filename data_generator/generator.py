from kafka import KafkaProducer
import json
import random
from datetime import datetime, timedelta
import time

# Configure Kafka Producer
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda x: json.dumps(x).encode('utf-8')
)

def generate_user_event():
    event_types = ['purchase', 'page_view', 'wishlist_add']
    product_ids = range(101, 110)
    user_ids = range(1, 100)
    
    event = {
        'event_type': random.choice(event_types),
        'user_id': random.choice(user_ids),
        'product_id': random.choice(product_ids),
        'timestamp': (datetime.now() - timedelta(minutes=random.randint(0, 60))).isoformat()
    }
    
    if event['event_type'] == 'purchase':
        event['amount'] = round(random.uniform(10, 500), 2)
    
    return event

def generate_product_metadata(event_type, user_id=None):
    user_id = user_id if event_type == "purchase" else None
    product_id = random.randint(101, 110)
    amount = round(random.uniform(10.00, 100.00), 2) if event_type == "purchase" else None
    stock = random.randint(1, 100) if event_type == "inventory_update" else None
    timestamp = datetime.now().isoformat() + "Z"
    
    return {
        "event_type": event_type,
        "user_id": user_id,
        "product_id": product_id,
        "amount": amount,
        "stock": stock,
        "timestamp": timestamp
    }

def simulate_data_stream():
    while True:
        # Generate and send user event
        event = generate_user_event()
        producer.send('user-events', event)
        print(event)
        # Generate and send product metadata
        if event['event_type'] in ['purchase', 'page_view']:
            metadata = generate_product_metadata(event['event_type'], event['user_id'])
            producer.send('product-metadata', metadata)
        if random.random() < 0.3:  # 30% chance to generate product metadata
            metadata = generate_product_metadata('inventory_update')
            producer.send('product-metadata', metadata)
        time.sleep(random.uniform(0.1, 1))  # Random delay between events

if __name__ == "__main__":
    print("Starting data generation...")
    simulate_data_stream()