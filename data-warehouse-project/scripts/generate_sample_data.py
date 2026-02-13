"""
Sample Data Generator
=====================
Generates realistic sample data for testing the data warehouse
Author: Your Name
Date: February 2026
"""

import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import random
from pathlib import Path

# Initialize Faker
fake = Faker()
Faker.seed(42)
np.random.seed(42)
random.seed(42)

# Create output directory
output_dir = Path('data/raw')
output_dir.mkdir(parents=True, exist_ok=True)

def generate_date_dimension(start_date='2020-01-01', end_date='2026-12-31'):
    """Generate date dimension data"""
    print("Generating Date Dimension...")
    
    date_range = pd.date_range(start=start_date, end=end_date, freq='D')
    
    dates = []
    for date in date_range:
        dates.append({
            'date_key': int(date.strftime('%Y%m%d')),
            'full_date': date.strftime('%Y-%m-%d'),
            'day_of_week': date.strftime('%A'),
            'day_of_week_num': date.weekday() + 1,
            'day_of_month': date.day,
            'day_of_year': date.timetuple().tm_yday,
            'week_of_year': date.isocalendar()[1],
            'month': date.month,
            'month_name': date.strftime('%B'),
            'quarter': (date.month - 1) // 3 + 1,
            'year': date.year,
            'is_weekend': date.weekday() >= 5,
            'is_holiday': date.month == 12 and date.day == 25,  # Simplified
            'holiday_name': 'Christmas' if (date.month == 12 and date.day == 25) else None,
            'fiscal_year': date.year if date.month >= 4 else date.year - 1,
            'fiscal_quarter': ((date.month - 4) % 12) // 3 + 1,
            'fiscal_month': ((date.month - 4) % 12) + 1
        })
    
    df = pd.DataFrame(dates)
    df.to_csv(output_dir / 'dim_date.csv', index=False)
    print(f"✓ Generated {len(df)} date records")
    return df

def generate_customers(n=5000):
    """Generate customer dimension data"""
    print("Generating Customer Dimension...")
    
    segments = ['VIP', 'Regular', 'Occasional', 'New']
    loyalty_tiers = ['Bronze', 'Silver', 'Gold', 'Platinum']
    
    customers = []
    for i in range(1, n + 1):
        reg_date = fake.date_between(start_date='-5y', end_date='today')
        
        customers.append({
            'customer_id': f'CUST{i:06d}',
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'email': fake.email(),
            'phone': fake.phone_number(),
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=80),
            'gender': random.choice(['Male', 'Female', 'Other']),
            'customer_segment': random.choice(segments),
            'customer_status': random.choice(['Active', 'Active', 'Active', 'Inactive']),
            'registration_date': reg_date,
            'street_address': fake.street_address(),
            'city': fake.city(),
            'state': fake.state(),
            'postal_code': fake.postcode(),
            'country': 'USA',
            'loyalty_program_member': random.choice([True, False]),
            'loyalty_tier': random.choice(loyalty_tiers)
        })
    
    df = pd.DataFrame(customers)
    df.to_csv(output_dir / 'customers.csv', index=False)
    print(f"✓ Generated {len(df)} customer records")
    return df

def generate_products(n=500):
    """Generate product dimension data"""
    print("Generating Product Dimension...")
    
    categories = {
        'Electronics': ['Smartphones', 'Laptops', 'Tablets', 'Accessories'],
        'Clothing': ['Men', 'Women', 'Kids', 'Accessories'],
        'Home & Garden': ['Furniture', 'Decor', 'Kitchen', 'Outdoor'],
        'Sports': ['Fitness', 'Outdoor', 'Team Sports', 'Water Sports'],
        'Books': ['Fiction', 'Non-Fiction', 'Educational', 'Children']
    }
    
    brands = ['BrandA', 'BrandB', 'BrandC', 'BrandD', 'BrandE', 'GenericBrand']
    
    products = []
    for i in range(1, n + 1):
        cat1 = random.choice(list(categories.keys()))
        cat2 = random.choice(categories[cat1])
        
        cost = round(random.uniform(10, 500), 2)
        price = round(cost * random.uniform(1.3, 2.5), 2)
        
        products.append({
            'product_id': f'PROD{i:05d}',
            'product_name': f'{fake.word().title()} {cat2} {i}',
            'brand': random.choice(brands),
            'category_level_1': cat1,
            'category_level_2': cat2,
            'category_level_3': fake.word().title(),
            'standard_cost': cost,
            'list_price': price,
            'product_status': random.choice(['Active', 'Active', 'Active', 'Discontinued']),
            'launch_date': fake.date_between(start_date='-3y', end_date='today')
        })
    
    df = pd.DataFrame(products)
    df.to_csv(output_dir / 'products.csv', index=False)
    print(f"✓ Generated {len(df)} product records")
    return df

def generate_stores(n=50):
    """Generate store dimension data"""
    print("Generating Store Dimension...")
    
    store_types = ['Flagship', 'Regular', 'Outlet', 'Pop-up']
    regions = ['Northeast', 'Southeast', 'Midwest', 'Southwest', 'West']
    
    stores = []
    for i in range(1, n + 1):
        stores.append({
            'store_id': f'STORE{i:03d}',
            'store_name': f'{fake.city()} {random.choice(store_types)}',
            'store_type': random.choice(store_types),
            'store_size_sqft': random.randint(1000, 10000),
            'city': fake.city(),
            'state': fake.state(),
            'country': 'USA',
            'region': random.choice(regions),
            'store_status': 'Open',
            'opening_date': fake.date_between(start_date='-10y', end_date='-1y')
        })
    
    df = pd.DataFrame(stores)
    df.to_csv(output_dir / 'stores.csv', index=False)
    print(f"✓ Generated {len(df)} store records")
    return df

def generate_promotions(n=100):
    """Generate promotion dimension data"""
    print("Generating Promotion Dimension...")
    
    promo_types = ['Percentage Discount', 'BOGO', 'Fixed Amount', 'Bundle Deal']
    
    promotions = []
    for i in range(1, n + 1):
        start = fake.date_between(start_date='-2y', end_date='today')
        end = start + timedelta(days=random.randint(7, 90))
        
        promotions.append({
            'promotion_id': f'PROMO{i:04d}',
            'promotion_name': f'{fake.word().title()} {random.choice(["Sale", "Deal", "Offer"])} {i}',
            'promotion_type': random.choice(promo_types),
            'discount_percentage': round(random.uniform(5, 50), 2),
            'start_date': start,
            'end_date': end,
            'promotion_status': 'Active' if end >= datetime.now().date() else 'Expired'
        })
    
    df = pd.DataFrame(promotions)
    df.to_csv(output_dir / 'promotions.csv', index=False)
    print(f"✓ Generated {len(df)} promotion records")
    return df

def generate_sales(customers_df, products_df, stores_df, promotions_df, n=50000):
    """Generate sales fact data"""
    print("Generating Sales Fact Data...")
    
    customer_ids = customers_df['customer_id'].tolist()
    product_ids = products_df['product_id'].tolist()
    store_ids = stores_df['store_id'].tolist()
    promotion_ids = ['NONE'] + promotions_df['promotion_id'].tolist()
    
    sales = []
    for i in range(1, n + 1):
        product_id = random.choice(product_ids)
        product_row = products_df[products_df['product_id'] == product_id].iloc[0]
        
        quantity = random.randint(1, 10)
        unit_price = product_row['list_price']
        discount_pct = random.uniform(0, 20) if random.random() < 0.3 else 0
        discount_amount = round(unit_price * quantity * (discount_pct / 100), 2)
        
        sales_amount = round(unit_price * quantity - discount_amount, 2)
        cost_amount = round(product_row['standard_cost'] * quantity, 2)
        
        transaction_date = fake.date_between(start_date='-1y', end_date='today')
        
        sales.append({
            'transaction_id': f'TXN{i:08d}',
            'date_key': int(transaction_date.strftime('%Y%m%d')),
            'customer_id': random.choice(customer_ids),
            'product_id': product_id,
            'store_id': random.choice(store_ids),
            'promotion_id': random.choice(promotion_ids),
            'quantity_sold': quantity,
            'unit_price': unit_price,
            'discount_amount': discount_amount,
            'sales_amount': sales_amount,
            'cost_amount': cost_amount,
            'tax_amount': round(sales_amount * 0.08, 2),
            'payment_method': random.choice(['Credit Card', 'Debit Card', 'Cash', 'Mobile Payment'])
        })
    
    df = pd.DataFrame(sales)
    df.to_csv(output_dir / 'sales.csv', index=False)
    print(f"✓ Generated {len(df)} sales transaction records")
    return df

def main():
    """Generate all sample data"""
    print("\n" + "=" * 60)
    print("SAMPLE DATA GENERATION")
    print("=" * 60 + "\n")
    
    # Generate dimensions
    date_df = generate_date_dimension()
    customers_df = generate_customers(n=5000)
    products_df = generate_products(n=500)
    stores_df = generate_stores(n=50)
    promotions_df = generate_promotions(n=100)
    
    # Generate facts
    sales_df = generate_sales(customers_df, products_df, stores_df, promotions_df, n=50000)
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Date Records:        {len(date_df):,}")
    print(f"Customer Records:    {len(customers_df):,}")
    print(f"Product Records:     {len(products_df):,}")
    print(f"Store Records:       {len(stores_df):,}")
    print(f"Promotion Records:   {len(promotions_df):,}")
    print(f"Sales Transactions:  {len(sales_df):,}")
    print("=" * 60)
    print(f"\nAll files saved to: {output_dir.absolute()}")
    print("\n✅ Sample data generation completed successfully!\n")

if __name__ == "__main__":
    main()
