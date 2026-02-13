-- ============================================
-- Data Warehouse Schema - Dimension Tables
-- ============================================
-- Author: Your Name
-- Date: February 2026
-- Description: Creates dimension tables for customer and product analytics
-- ============================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_time CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_promotion CASCADE;
DROP TABLE IF EXISTS dim_channel CASCADE;

-- ============================================
-- DIM_DATE: Date Dimension
-- ============================================
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_week VARCHAR(10) NOT NULL,
    day_of_week_num INTEGER NOT NULL CHECK (day_of_week_num BETWEEN 1 AND 7),
    day_of_month INTEGER NOT NULL CHECK (day_of_month BETWEEN 1 AND 31),
    day_of_year INTEGER NOT NULL CHECK (day_of_year BETWEEN 1 AND 366),
    week_of_year INTEGER NOT NULL CHECK (week_of_year BETWEEN 1 AND 53),
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name VARCHAR(10) NOT NULL,
    quarter INTEGER NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    year INTEGER NOT NULL,
    is_weekend BOOLEAN NOT NULL DEFAULT FALSE,
    is_holiday BOOLEAN NOT NULL DEFAULT FALSE,
    holiday_name VARCHAR(50),
    fiscal_year INTEGER NOT NULL,
    fiscal_quarter INTEGER NOT NULL CHECK (fiscal_quarter BETWEEN 1 AND 4),
    fiscal_month INTEGER NOT NULL CHECK (fiscal_month BETWEEN 1 AND 12)
);

COMMENT ON TABLE dim_date IS 'Date dimension for time-based analysis';
COMMENT ON COLUMN dim_date.date_key IS 'Surrogate key in YYYYMMDD format';
COMMENT ON COLUMN dim_date.fiscal_year IS 'Fiscal year (may differ from calendar year)';

-- ============================================
-- DIM_TIME: Time of Day Dimension
-- ============================================
CREATE TABLE dim_time (
    time_key INTEGER PRIMARY KEY,
    full_time TIME NOT NULL UNIQUE,
    hour INTEGER NOT NULL CHECK (hour BETWEEN 0 AND 23),
    minute INTEGER NOT NULL CHECK (minute BETWEEN 0 AND 59),
    second INTEGER NOT NULL CHECK (second BETWEEN 0 AND 59),
    am_pm VARCHAR(2) NOT NULL CHECK (am_pm IN ('AM', 'PM')),
    day_part VARCHAR(20) NOT NULL CHECK (day_part IN ('Morning', 'Afternoon', 'Evening', 'Night')),
    business_hours_flag BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE dim_time IS 'Time dimension for intraday analysis';
COMMENT ON COLUMN dim_time.time_key IS 'Surrogate key in HHMMSS format';

-- ============================================
-- DIM_CUSTOMER: Customer Dimension (SCD Type 2)
-- ============================================
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    email VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    age INTEGER,
    age_group VARCHAR(20),
    gender VARCHAR(20),
    marital_status VARCHAR(20),
    education_level VARCHAR(50),
    occupation VARCHAR(50),
    income_range VARCHAR(30),
    customer_segment VARCHAR(50),
    customer_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    registration_date DATE,
    lifetime_value DECIMAL(12,2) DEFAULT 0.00,
    total_purchases INTEGER DEFAULT 0,
    street_address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    loyalty_program_member BOOLEAN DEFAULT FALSE,
    loyalty_tier VARCHAR(20),
    -- SCD Type 2 columns
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE DEFAULT '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_age_positive CHECK (age >= 0),
    CONSTRAINT chk_dates CHECK (expiration_date >= effective_date)
);

-- Create unique index for natural key + effective date
CREATE UNIQUE INDEX idx_customer_natural_key ON dim_customer(customer_id, effective_date);
CREATE INDEX idx_customer_segment ON dim_customer(customer_segment) WHERE is_current = TRUE;
CREATE INDEX idx_customer_status ON dim_customer(customer_status) WHERE is_current = TRUE;
CREATE INDEX idx_customer_current ON dim_customer(is_current);
CREATE INDEX idx_customer_city_state ON dim_customer(city, state) WHERE is_current = TRUE;

COMMENT ON TABLE dim_customer IS 'Customer dimension with SCD Type 2 for historical tracking';
COMMENT ON COLUMN dim_customer.customer_key IS 'Surrogate key for customer dimension';
COMMENT ON COLUMN dim_customer.customer_id IS 'Natural business key from source system';
COMMENT ON COLUMN dim_customer.is_current IS 'Flag indicating current/active record';

-- ============================================
-- DIM_PRODUCT: Product Dimension (SCD Type 2)
-- ============================================
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    product_description TEXT,
    brand VARCHAR(50),
    manufacturer VARCHAR(50),
    category_level_1 VARCHAR(50),
    category_level_2 VARCHAR(50),
    category_level_3 VARCHAR(50),
    product_line VARCHAR(50),
    unit_of_measure VARCHAR(20),
    package_size VARCHAR(30),
    weight DECIMAL(10,2),
    weight_unit VARCHAR(10),
    color VARCHAR(30),
    size VARCHAR(20),
    standard_cost DECIMAL(10,2),
    list_price DECIMAL(10,2),
    margin_percentage DECIMAL(5,2) GENERATED ALWAYS AS 
        (CASE WHEN list_price > 0 THEN ((list_price - standard_cost) / list_price * 100) ELSE 0 END) STORED,
    launch_date DATE,
    discontinue_date DATE,
    product_status VARCHAR(20) DEFAULT 'Active',
    is_featured BOOLEAN DEFAULT FALSE,
    is_seasonal BOOLEAN DEFAULT FALSE,
    season VARCHAR(20),
    -- SCD Type 2 columns
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE DEFAULT '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_product_dates CHECK (expiration_date >= effective_date),
    CONSTRAINT chk_positive_cost CHECK (standard_cost >= 0),
    CONSTRAINT chk_positive_price CHECK (list_price >= 0)
);

-- Create unique index for natural key + effective date
CREATE UNIQUE INDEX idx_product_natural_key ON dim_product(product_id, effective_date);
CREATE INDEX idx_product_category ON dim_product(category_level_1, category_level_2, category_level_3) WHERE is_current = TRUE;
CREATE INDEX idx_product_brand ON dim_product(brand) WHERE is_current = TRUE;
CREATE INDEX idx_product_status ON dim_product(product_status) WHERE is_current = TRUE;
CREATE INDEX idx_product_current ON dim_product(is_current);

COMMENT ON TABLE dim_product IS 'Product dimension with hierarchical categories and SCD Type 2';
COMMENT ON COLUMN dim_product.product_key IS 'Surrogate key for product dimension';
COMMENT ON COLUMN dim_product.product_id IS 'Natural business key (SKU) from source system';

-- ============================================
-- DIM_STORE: Store/Location Dimension
-- ============================================
CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id VARCHAR(50) UNIQUE NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    store_type VARCHAR(30),
    store_size_sqft INTEGER,
    store_format VARCHAR(30),
    manager_name VARCHAR(100),
    street_address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    region VARCHAR(50),
    district VARCHAR(50),
    timezone VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    opening_date DATE,
    closing_date DATE,
    store_status VARCHAR(20) DEFAULT 'Open',
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_store_status CHECK (store_status IN ('Open', 'Closed', 'Renovating', 'Under Construction')),
    CONSTRAINT chk_store_dates CHECK (closing_date IS NULL OR closing_date >= opening_date)
);

CREATE INDEX idx_store_region ON dim_store(region);
CREATE INDEX idx_store_status ON dim_store(store_status);
CREATE INDEX idx_store_location ON dim_store(city, state, country);

COMMENT ON TABLE dim_store IS 'Store/location dimension';
COMMENT ON COLUMN dim_store.store_key IS 'Surrogate key for store dimension';
COMMENT ON COLUMN dim_store.region IS 'Geographic sales region';

-- ============================================
-- DIM_PROMOTION: Promotion Dimension
-- ============================================
CREATE TABLE dim_promotion (
    promotion_key SERIAL PRIMARY KEY,
    promotion_id VARCHAR(50) UNIQUE NOT NULL,
    promotion_name VARCHAR(100) NOT NULL,
    promotion_type VARCHAR(50),
    promotion_category VARCHAR(50),
    discount_percentage DECIMAL(5,2),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    promotion_status VARCHAR(20) DEFAULT 'Planned',
    media_type VARCHAR(50),
    campaign_name VARCHAR(100),
    budget DECIMAL(12,2),
    target_audience VARCHAR(100),
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_promotion_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_discount CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
    CONSTRAINT chk_promo_status CHECK (promotion_status IN ('Planned', 'Active', 'Expired', 'Cancelled'))
);

CREATE INDEX idx_promotion_dates ON dim_promotion(start_date, end_date);
CREATE INDEX idx_promotion_status ON dim_promotion(promotion_status);
CREATE INDEX idx_promotion_type ON dim_promotion(promotion_type);

COMMENT ON TABLE dim_promotion IS 'Promotion dimension for marketing analytics';
COMMENT ON COLUMN dim_promotion.promotion_key IS 'Surrogate key for promotion dimension';

-- ============================================
-- DIM_CHANNEL: Sales/Interaction Channel Dimension
-- ============================================
CREATE TABLE dim_channel (
    channel_key SERIAL PRIMARY KEY,
    channel_id VARCHAR(50) UNIQUE NOT NULL,
    channel_name VARCHAR(50) NOT NULL,
    channel_type VARCHAR(30),
    channel_category VARCHAR(30),
    description VARCHAR(200),
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_channel_type CHECK (channel_type IN ('Online', 'In-Store', 'Mobile', 'Call Center', 'Social Media', 'Email')),
    CONSTRAINT chk_channel_category CHECK (channel_category IN ('Digital', 'Physical', 'Hybrid'))
);

CREATE INDEX idx_channel_type ON dim_channel(channel_type);

COMMENT ON TABLE dim_channel IS 'Sales and interaction channel dimension';

-- ============================================
-- Insert "Unknown" or "Not Applicable" records
-- ============================================

-- Unknown Customer
INSERT INTO dim_customer (customer_key, customer_id, first_name, last_name, customer_segment, customer_status)
VALUES (0, 'UNKNOWN', 'Unknown', 'Customer', 'Unknown', 'Unknown');

-- Unknown Product
INSERT INTO dim_product (product_key, product_id, product_name, product_status)
VALUES (0, 'UNKNOWN', 'Unknown Product', 'Unknown');

-- Unknown Store
INSERT INTO dim_store (store_key, store_id, store_name, store_status)
VALUES (0, 'UNKNOWN', 'Unknown Store', 'Unknown');

-- No Promotion
INSERT INTO dim_promotion (promotion_key, promotion_id, promotion_name, start_date, end_date, promotion_status)
VALUES (0, 'NONE', 'No Promotion', '1900-01-01', '9999-12-31', 'Active');

-- Unknown Channel
INSERT INTO dim_channel (channel_key, channel_id, channel_name, channel_type, channel_category)
VALUES (0, 'UNKNOWN', 'Unknown Channel', 'Online', 'Digital');

-- ============================================
-- Grant permissions (adjust as needed)
-- ============================================
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO etl_user;

-- ============================================
-- Schema creation completed successfully
-- ============================================
