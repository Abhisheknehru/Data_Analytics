# Data Dictionary

## Overview
This document provides detailed descriptions of all tables, columns, and data elements in the data warehouse.

---

## Dimension Tables

### DIM_DATE
**Purpose**: Calendar dimension for time-based analysis

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| date_key | INTEGER | Primary key in YYYYMMDD format | 20240115 |
| full_date | DATE | Complete date value | 2024-01-15 |
| day_of_week | VARCHAR(10) | Name of day | Monday |
| day_of_week_num | INTEGER | Day number (1=Monday, 7=Sunday) | 1 |
| day_of_month | INTEGER | Day within month (1-31) | 15 |
| day_of_year | INTEGER | Day within year (1-366) | 15 |
| week_of_year | INTEGER | ISO week number (1-53) | 3 |
| month | INTEGER | Month number (1-12) | 1 |
| month_name | VARCHAR(10) | Month name | January |
| quarter | INTEGER | Quarter (1-4) | 1 |
| year | INTEGER | Year | 2024 |
| is_weekend | BOOLEAN | Weekend indicator | false |
| is_holiday | BOOLEAN | Holiday indicator | false |
| holiday_name | VARCHAR(50) | Name of holiday if applicable | NULL |
| fiscal_year | INTEGER | Fiscal year | 2024 |
| fiscal_quarter | INTEGER | Fiscal quarter | 3 |
| fiscal_month | INTEGER | Fiscal month | 10 |

---

### DIM_CUSTOMER
**Purpose**: Customer demographic and behavioral attributes (SCD Type 2)

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| customer_key | SERIAL | Surrogate primary key | 1001 |
| customer_id | VARCHAR(50) | Natural business key | CUST000123 |
| first_name | VARCHAR(50) | Customer first name | John |
| last_name | VARCHAR(50) | Customer last name | Smith |
| full_name | VARCHAR(101) | Computed full name | John Smith |
| email | VARCHAR(100) | Email address | john.smith@email.com |
| phone | VARCHAR(20) | Phone number | 555-0123 |
| date_of_birth | DATE | Birth date | 1985-03-15 |
| age | INTEGER | Current age | 39 |
| age_group | VARCHAR(20) | Age range category | 35-44 |
| gender | VARCHAR(20) | Gender | Male |
| marital_status | VARCHAR(20) | Marital status | Married |
| education_level | VARCHAR(50) | Education level | Bachelor's Degree |
| occupation | VARCHAR(50) | Occupation | Software Engineer |
| income_range | VARCHAR(30) | Income bracket | $75K-$100K |
| customer_segment | VARCHAR(50) | Business segment | VIP |
| customer_status | VARCHAR(20) | Account status | Active |
| registration_date | DATE | Registration date | 2020-01-15 |
| lifetime_value | DECIMAL(12,2) | Total customer value | 15432.50 |
| total_purchases | INTEGER | Number of purchases | 47 |
| street_address | VARCHAR(100) | Street address | 123 Main St |
| city | VARCHAR(50) | City | New York |
| state | VARCHAR(50) | State/Province | NY |
| postal_code | VARCHAR(20) | ZIP/Postal code | 10001 |
| country | VARCHAR(50) | Country | USA |
| loyalty_program_member | BOOLEAN | Loyalty membership | true |
| loyalty_tier | VARCHAR(20) | Loyalty tier | Gold |
| effective_date | DATE | SCD2: Record start date | 2024-01-01 |
| expiration_date | DATE | SCD2: Record end date | 9999-12-31 |
| is_current | BOOLEAN | SCD2: Current record flag | true |
| created_at | TIMESTAMP | Record creation time | 2024-01-01 10:30:00 |
| updated_at | TIMESTAMP | Last update time | 2024-01-15 14:22:00 |

**Business Rules**:
- One customer can have multiple records if attributes changed (SCD Type 2)
- Only records with `is_current = TRUE` represent current state
- `customer_segment` values: VIP, Regular, Occasional, New
- `loyalty_tier` values: Bronze, Silver, Gold, Platinum

---

### DIM_PRODUCT
**Purpose**: Product catalog with hierarchical categories (SCD Type 2)

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| product_key | SERIAL | Surrogate primary key | 2001 |
| product_id | VARCHAR(50) | Natural business key (SKU) | PROD00456 |
| product_name | VARCHAR(100) | Product name | Wireless Bluetooth Headphones |
| product_description | TEXT | Detailed description | Premium noise-canceling... |
| brand | VARCHAR(50) | Brand name | SoundWave |
| manufacturer | VARCHAR(50) | Manufacturer | TechCorp Inc. |
| category_level_1 | VARCHAR(50) | Top-level category | Electronics |
| category_level_2 | VARCHAR(50) | Mid-level category | Audio |
| category_level_3 | VARCHAR(50) | Detailed category | Headphones |
| product_line | VARCHAR(50) | Product line | Professional Series |
| unit_of_measure | VARCHAR(20) | Unit of measure | Each |
| package_size | VARCHAR(30) | Package description | Single Unit |
| weight | DECIMAL(10,2) | Product weight | 0.25 |
| weight_unit | VARCHAR(10) | Weight unit | Kg |
| color | VARCHAR(30) | Product color | Black |
| size | VARCHAR(20) | Product size | One Size |
| standard_cost | DECIMAL(10,2) | Cost per unit | 45.00 |
| list_price | DECIMAL(10,2) | Retail price | 99.99 |
| margin_percentage | DECIMAL(5,2) | Computed profit margin % | 55.00 |
| launch_date | DATE | Product launch date | 2023-06-01 |
| discontinue_date | DATE | Discontinuation date | NULL |
| product_status | VARCHAR(20) | Status | Active |
| is_featured | BOOLEAN | Featured product flag | true |
| is_seasonal | BOOLEAN | Seasonal product flag | false |
| season | VARCHAR(20) | Season if applicable | NULL |
| effective_date | DATE | SCD2: Record start date | 2024-01-01 |
| expiration_date | DATE | SCD2: Record end date | 9999-12-31 |
| is_current | BOOLEAN | SCD2: Current record flag | true |
| created_at | TIMESTAMP | Record creation time | 2023-06-01 08:00:00 |
| updated_at | TIMESTAMP | Last update time | 2024-01-10 11:45:00 |

**Business Rules**:
- Three-level category hierarchy: Level 1 (Dept) → Level 2 (Category) → Level 3 (Subcategory)
- Price changes trigger new SCD Type 2 record
- `product_status` values: Active, Discontinued, Out of Stock

---

### DIM_STORE
**Purpose**: Store/location information

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| store_key | SERIAL | Surrogate primary key | 501 |
| store_id | VARCHAR(50) | Natural business key | STORE042 |
| store_name | VARCHAR(100) | Store name | Manhattan Flagship |
| store_type | VARCHAR(30) | Store type | Flagship |
| store_size_sqft | INTEGER | Store size in sq ft | 25000 |
| store_format | VARCHAR(30) | Store format | Mall |
| manager_name | VARCHAR(100) | Store manager | Jane Doe |
| street_address | VARCHAR(100) | Street address | 500 5th Avenue |
| city | VARCHAR(50) | City | New York |
| state | VARCHAR(50) | State/Province | NY |
| postal_code | VARCHAR(20) | ZIP/Postal code | 10110 |
| country | VARCHAR(50) | Country | USA |
| region | VARCHAR(50) | Sales region | Northeast |
| district | VARCHAR(50) | Sales district | Metro NYC |
| timezone | VARCHAR(50) | Timezone | America/New_York |
| phone | VARCHAR(20) | Store phone | 212-555-0100 |
| email | VARCHAR(100) | Store email | nyc.flagship@store.com |
| opening_date | DATE | Store opening date | 2015-03-01 |
| closing_date | DATE | Store closing date | NULL |
| store_status | VARCHAR(20) | Status | Open |
| latitude | DECIMAL(10,6) | GPS latitude | 40.754932 |
| longitude | DECIMAL(10,6) | GPS longitude | -73.984016 |
| created_at | TIMESTAMP | Record creation time | 2015-03-01 00:00:00 |
| updated_at | TIMESTAMP | Last update time | 2024-01-01 00:00:00 |

**Business Rules**:
- `store_type` values: Flagship, Regular, Outlet, Pop-up
- `store_status` values: Open, Closed, Renovating, Under Construction
- Geographic hierarchy: Region → State → City

---

### DIM_PROMOTION
**Purpose**: Marketing promotions and campaigns

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| promotion_key | SERIAL | Surrogate primary key | 301 |
| promotion_id | VARCHAR(50) | Natural business key | PROMO2024Q1 |
| promotion_name | VARCHAR(100) | Promotion name | Spring Sale 2024 |
| promotion_type | VARCHAR(50) | Type of promotion | Percentage Discount |
| promotion_category | VARCHAR(50) | Promotion category | Seasonal |
| discount_percentage | DECIMAL(5,2) | Discount percentage | 20.00 |
| start_date | DATE | Promotion start date | 2024-03-01 |
| end_date | DATE | Promotion end date | 2024-03-31 |
| promotion_status | VARCHAR(20) | Status | Active |
| media_type | VARCHAR(50) | Media channel | Email + Social |
| campaign_name | VARCHAR(100) | Campaign name | Spring Refresh |
| budget | DECIMAL(12,2) | Campaign budget | 50000.00 |
| target_audience | VARCHAR(100) | Target segment | All Customers |
| created_at | TIMESTAMP | Record creation time | 2024-02-15 09:00:00 |
| updated_at | TIMESTAMP | Last update time | 2024-02-15 09:00:00 |

**Business Rules**:
- `promotion_type` values: Percentage Discount, BOGO, Fixed Amount, Bundle Deal
- `promotion_status` values: Planned, Active, Expired, Cancelled
- Promotion key of 0 indicates "No Promotion"

---

## Fact Tables

### FACT_SALES
**Purpose**: Transaction-level sales data

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| sales_key | BIGSERIAL | Surrogate primary key | 100001 |
| date_key | INTEGER | Foreign key to dim_date | 20240115 |
| time_key | INTEGER | Foreign key to dim_time | 143000 |
| customer_key | INTEGER | Foreign key to dim_customer | 1001 |
| product_key | INTEGER | Foreign key to dim_product | 2001 |
| store_key | INTEGER | Foreign key to dim_store | 501 |
| promotion_key | INTEGER | Foreign key to dim_promotion | 301 |
| transaction_id | VARCHAR(50) | Original transaction ID | TXN20240115001 |
| invoice_number | VARCHAR(50) | Invoice number | INV-2024-001234 |
| quantity_sold | DECIMAL(10,2) | Quantity sold | 2.00 |
| unit_price | DECIMAL(10,2) | Price per unit | 99.99 |
| discount_amount | DECIMAL(10,2) | Total discount | 20.00 |
| sales_amount | DECIMAL(12,2) | Net sales amount | 179.98 |
| cost_amount | DECIMAL(12,2) | Cost of goods sold | 90.00 |
| profit_amount | DECIMAL(12,2) | Profit (computed) | 89.98 |
| tax_amount | DECIMAL(10,2) | Sales tax | 14.40 |
| shipping_amount | DECIMAL(10,2) | Shipping charges | 5.99 |
| profit_margin_pct | DECIMAL(5,2) | Profit margin % (computed) | 50.00 |
| discount_pct | DECIMAL(5,2) | Discount % (computed) | 10.00 |
| payment_method | VARCHAR(30) | Payment method | Credit Card |
| return_flag | BOOLEAN | Return indicator | false |
| created_at | TIMESTAMP | Record creation time | 2024-01-15 14:30:00 |
| updated_at | TIMESTAMP | Last update time | 2024-01-15 14:30:00 |

**Calculated Fields**:
- `profit_amount = sales_amount - cost_amount`
- `profit_margin_pct = (profit_amount / sales_amount) * 100`
- `discount_pct = (discount_amount / (sales_amount + discount_amount)) * 100`

**Business Rules**:
- Grain: One row per product per transaction
- Multi-item transactions have multiple rows
- Returns are tracked separately with `return_flag = TRUE`

---

### FACT_CUSTOMER_INTERACTION
**Purpose**: Customer touchpoints and engagement

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| interaction_key | BIGSERIAL | Surrogate primary key | 200001 |
| date_key | INTEGER | Foreign key to dim_date | 20240115 |
| time_key | INTEGER | Foreign key to dim_time | 100000 |
| customer_key | INTEGER | Foreign key to dim_customer | 1001 |
| channel_key | INTEGER | Foreign key to dim_channel | 1 |
| store_key | INTEGER | Foreign key to dim_store (optional) | 501 |
| interaction_id | VARCHAR(50) | Unique interaction ID | INT20240115001 |
| session_id | VARCHAR(50) | Web session ID | SESSION123ABC |
| interaction_type | VARCHAR(50) | Type of interaction | Visit |
| interaction_subtype | VARCHAR(50) | Subtype | Product Browse |
| duration_seconds | INTEGER | Duration in seconds | 450 |
| page_views | INTEGER | Number of pages viewed | 12 |
| items_viewed | INTEGER | Items viewed | 8 |
| items_added_to_cart | INTEGER | Items added to cart | 2 |
| satisfaction_score | DECIMAL(3,2) | Satisfaction rating (0-5) | 4.50 |
| resolved_flag | BOOLEAN | Issue resolved | true |
| conversion_flag | BOOLEAN | Converted to sale | true |
| notes | TEXT | Additional notes | Customer requested... |
| agent_id | VARCHAR(50) | Support agent ID | AGENT042 |
| created_at | TIMESTAMP | Record creation time | 2024-01-15 10:00:00 |

**Business Rules**:
- `interaction_type` values: Visit, Call, Email, Chat, Social, Support, Complaint, Inquiry
- `satisfaction_score` range: 0.00 to 5.00
- Duration and page views only applicable for digital interactions

---

### FACT_PRODUCT_INVENTORY
**Purpose**: Periodic snapshot of inventory levels

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| inventory_key | BIGSERIAL | Surrogate primary key | 300001 |
| date_key | INTEGER | Foreign key to dim_date | 20240115 |
| product_key | INTEGER | Foreign key to dim_product | 2001 |
| store_key | INTEGER | Foreign key to dim_store | 501 |
| quantity_on_hand | INTEGER | Current inventory | 150 |
| quantity_on_order | INTEGER | Units on order | 200 |
| quantity_reserved | INTEGER | Reserved units | 25 |
| quantity_available | INTEGER | Available units (computed) | 125 |
| reorder_point | INTEGER | Reorder threshold | 50 |
| reorder_quantity | INTEGER | Standard reorder qty | 200 |
| unit_cost | DECIMAL(10,2) | Current unit cost | 45.00 |
| inventory_value | DECIMAL(12,2) | Total value (computed) | 6750.00 |
| days_of_supply | INTEGER | Estimated days | 30 |
| stockout_flag | BOOLEAN | Out of stock (computed) | false |
| overstock_flag | BOOLEAN | Overstock indicator | false |
| snapshot_timestamp | TIMESTAMP | Snapshot time | 2024-01-15 23:59:59 |
| created_at | TIMESTAMP | Record creation time | 2024-01-16 00:05:00 |

**Calculated Fields**:
- `quantity_available = quantity_on_hand - quantity_reserved`
- `inventory_value = quantity_on_hand * unit_cost`
- `stockout_flag = (quantity_on_hand <= 0)`

**Business Rules**:
- Grain: Daily snapshot per product per store
- Snapshot taken at end of business day
- One record per product-store-date combination

---

## Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-13 | 1.0 | Initial version | Your Name |

