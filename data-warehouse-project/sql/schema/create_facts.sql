-- ============================================
-- Data Warehouse Schema - Fact Tables
-- ============================================
-- Author: Your Name
-- Date: February 2026
-- Description: Creates fact tables for customer and product analytics
-- ============================================

-- Drop existing fact tables if they exist
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS fact_customer_interaction CASCADE;
DROP TABLE IF EXISTS fact_product_inventory CASCADE;

-- ============================================
-- FACT_SALES: Primary Sales Fact Table
-- ============================================
CREATE TABLE fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,
    
    -- Foreign Keys to Dimensions
    date_key INTEGER NOT NULL,
    time_key INTEGER,
    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    promotion_key INTEGER DEFAULT 0,
    
    -- Degenerate Dimensions
    transaction_id VARCHAR(50) NOT NULL,
    invoice_number VARCHAR(50),
    
    -- Measures/Facts
    quantity_sold DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    sales_amount DECIMAL(12,2) NOT NULL,
    cost_amount DECIMAL(12,2) NOT NULL,
    profit_amount DECIMAL(12,2) GENERATED ALWAYS AS (sales_amount - cost_amount) STORED,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_amount DECIMAL(10,2) DEFAULT 0.00,
    
    -- Calculated Metrics
    profit_margin_pct DECIMAL(5,2) GENERATED ALWAYS AS 
        (CASE WHEN sales_amount > 0 THEN (profit_amount / sales_amount * 100) ELSE 0 END) STORED,
    discount_pct DECIMAL(5,2) GENERATED ALWAYS AS 
        (CASE WHEN sales_amount + discount_amount > 0 THEN (discount_amount / (sales_amount + discount_amount) * 100) ELSE 0 END) STORED,
    
    -- Additional Attributes
    payment_method VARCHAR(30),
    return_flag BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_quantity_positive CHECK (quantity_sold > 0),
    CONSTRAINT chk_amounts_positive CHECK (sales_amount >= 0 AND cost_amount >= 0),
    CONSTRAINT chk_discount_valid CHECK (discount_amount >= 0),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_sales_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_sales_time FOREIGN KEY (time_key) REFERENCES dim_time(time_key),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    CONSTRAINT fk_sales_store FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    CONSTRAINT fk_sales_promotion FOREIGN KEY (promotion_key) REFERENCES dim_promotion(promotion_key)
);

-- Indexes for query performance
CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_store ON fact_sales(store_key);
CREATE INDEX idx_fact_sales_promotion ON fact_sales(promotion_key) WHERE promotion_key != 0;
CREATE INDEX idx_fact_sales_transaction ON fact_sales(transaction_id);
CREATE INDEX idx_fact_sales_date_customer ON fact_sales(date_key, customer_key);
CREATE INDEX idx_fact_sales_date_product ON fact_sales(date_key, product_key);

COMMENT ON TABLE fact_sales IS 'Primary fact table containing sales transactions';
COMMENT ON COLUMN fact_sales.sales_key IS 'Surrogate key for fact table';
COMMENT ON COLUMN fact_sales.transaction_id IS 'Degenerate dimension - original transaction ID';
COMMENT ON COLUMN fact_sales.sales_amount IS 'Total sales amount (quantity × unit_price - discount)';
COMMENT ON COLUMN fact_sales.profit_amount IS 'Calculated profit (sales_amount - cost_amount)';

-- ============================================
-- FACT_CUSTOMER_INTERACTION: Customer Touchpoints
-- ============================================
CREATE TABLE fact_customer_interaction (
    interaction_key BIGSERIAL PRIMARY KEY,
    
    -- Foreign Keys to Dimensions
    date_key INTEGER NOT NULL,
    time_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    channel_key INTEGER NOT NULL,
    store_key INTEGER,
    
    -- Degenerate Dimensions
    interaction_id VARCHAR(50) NOT NULL UNIQUE,
    session_id VARCHAR(50),
    
    -- Attributes
    interaction_type VARCHAR(50) NOT NULL,
    interaction_subtype VARCHAR(50),
    
    -- Measures
    duration_seconds INTEGER,
    page_views INTEGER,
    items_viewed INTEGER,
    items_added_to_cart INTEGER,
    satisfaction_score DECIMAL(3,2),
    resolved_flag BOOLEAN DEFAULT FALSE,
    conversion_flag BOOLEAN DEFAULT FALSE,
    
    -- Additional Data
    notes TEXT,
    agent_id VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_duration_positive CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CONSTRAINT chk_satisfaction_range CHECK (satisfaction_score IS NULL OR (satisfaction_score >= 0 AND satisfaction_score <= 5)),
    CONSTRAINT chk_interaction_type CHECK (interaction_type IN ('Visit', 'Call', 'Email', 'Chat', 'Social', 'Support', 'Complaint', 'Inquiry')),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_interaction_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_interaction_time FOREIGN KEY (time_key) REFERENCES dim_time(time_key),
    CONSTRAINT fk_interaction_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_interaction_channel FOREIGN KEY (channel_key) REFERENCES dim_channel(channel_key),
    CONSTRAINT fk_interaction_store FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);

-- Indexes
CREATE INDEX idx_fact_interaction_date ON fact_customer_interaction(date_key);
CREATE INDEX idx_fact_interaction_customer ON fact_customer_interaction(customer_key);
CREATE INDEX idx_fact_interaction_channel ON fact_customer_interaction(channel_key);
CREATE INDEX idx_fact_interaction_type ON fact_customer_interaction(interaction_type);
CREATE INDEX idx_fact_interaction_date_customer ON fact_customer_interaction(date_key, customer_key);

COMMENT ON TABLE fact_customer_interaction IS 'Fact table tracking customer interactions and touchpoints';
COMMENT ON COLUMN fact_customer_interaction.interaction_type IS 'Type of customer interaction';
COMMENT ON COLUMN fact_customer_interaction.satisfaction_score IS 'Customer satisfaction rating (0-5 scale)';

-- ============================================
-- FACT_PRODUCT_INVENTORY: Periodic Inventory Snapshot
-- ============================================
CREATE TABLE fact_product_inventory (
    inventory_key BIGSERIAL PRIMARY KEY,
    
    -- Foreign Keys to Dimensions
    date_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    
    -- Snapshot Measures
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    quantity_on_order INTEGER DEFAULT 0,
    quantity_reserved INTEGER DEFAULT 0,
    quantity_available INTEGER GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    
    -- Value Metrics
    unit_cost DECIMAL(10,2),
    inventory_value DECIMAL(12,2) GENERATED ALWAYS AS (quantity_on_hand * unit_cost) STORED,
    
    -- Additional Measures
    days_of_supply INTEGER,
    stockout_flag BOOLEAN GENERATED ALWAYS AS (quantity_on_hand <= 0) STORED,
    overstock_flag BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    snapshot_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_quantities_non_negative CHECK (
        quantity_on_hand >= 0 AND 
        quantity_on_order >= 0 AND 
        quantity_reserved >= 0
    ),
    CONSTRAINT chk_unit_cost_positive CHECK (unit_cost IS NULL OR unit_cost >= 0),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_inventory_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    CONSTRAINT fk_inventory_store FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    
    -- Unique constraint to prevent duplicate snapshots
    CONSTRAINT uq_inventory_snapshot UNIQUE (date_key, product_key, store_key)
);

-- Indexes
CREATE INDEX idx_fact_inventory_date ON fact_product_inventory(date_key);
CREATE INDEX idx_fact_inventory_product ON fact_product_inventory(product_key);
CREATE INDEX idx_fact_inventory_store ON fact_product_inventory(store_key);
CREATE INDEX idx_fact_inventory_stockout ON fact_product_inventory(stockout_flag) WHERE stockout_flag = TRUE;
CREATE INDEX idx_fact_inventory_date_product ON fact_product_inventory(date_key, product_key);

COMMENT ON TABLE fact_product_inventory IS 'Periodic snapshot fact table for inventory levels';
COMMENT ON COLUMN fact_product_inventory.quantity_on_hand IS 'Current inventory quantity available';
COMMENT ON COLUMN fact_product_inventory.quantity_available IS 'Quantity available for sale (on_hand - reserved)';
COMMENT ON COLUMN fact_product_inventory.stockout_flag IS 'Flag indicating out-of-stock condition';

-- ============================================
-- Aggregate/Summary Tables (Optional)
-- ============================================

-- Daily Sales Summary
CREATE TABLE fact_sales_daily_summary (
    summary_key BIGSERIAL PRIMARY KEY,
    date_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    
    -- Aggregated Measures
    total_quantity_sold DECIMAL(12,2),
    total_sales_amount DECIMAL(14,2),
    total_cost_amount DECIMAL(14,2),
    total_profit_amount DECIMAL(14,2),
    transaction_count INTEGER,
    unique_customers INTEGER,
    avg_transaction_value DECIMAL(10,2),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_summary_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_summary_store FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    CONSTRAINT fk_summary_product FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    
    -- Unique constraint
    CONSTRAINT uq_daily_summary UNIQUE (date_key, store_key, product_key)
);

CREATE INDEX idx_summary_date ON fact_sales_daily_summary(date_key);
CREATE INDEX idx_summary_store ON fact_sales_daily_summary(store_key);
CREATE INDEX idx_summary_product ON fact_sales_daily_summary(product_key);

COMMENT ON TABLE fact_sales_daily_summary IS 'Pre-aggregated daily sales summary for faster querying';

-- ============================================
-- Materialized Views for Common Queries
-- ============================================

-- Monthly Sales by Category
CREATE MATERIALIZED VIEW mv_monthly_sales_by_category AS
SELECT 
    d.year,
    d.month,
    d.month_name,
    p.category_level_1,
    p.category_level_2,
    s.region,
    SUM(f.sales_amount) as total_sales,
    SUM(f.profit_amount) as total_profit,
    SUM(f.quantity_sold) as total_units,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    COUNT(DISTINCT f.transaction_id) as transaction_count,
    AVG(f.sales_amount) as avg_transaction_value
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key AND p.is_current = TRUE
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY d.year, d.month, d.month_name, p.category_level_1, p.category_level_2, s.region;

CREATE INDEX idx_mv_monthly_year_month ON mv_monthly_sales_by_category(year, month);
CREATE INDEX idx_mv_monthly_category ON mv_monthly_sales_by_category(category_level_1, category_level_2);

COMMENT ON MATERIALIZED VIEW mv_monthly_sales_by_category IS 'Pre-aggregated monthly sales data by product category';

-- Customer Lifetime Value Summary
CREATE MATERIALIZED VIEW mv_customer_ltv_summary AS
SELECT 
    c.customer_key,
    c.customer_id,
    c.customer_segment,
    c.loyalty_tier,
    COUNT(DISTINCT f.transaction_id) as total_transactions,
    SUM(f.sales_amount) as lifetime_sales,
    SUM(f.profit_amount) as lifetime_profit,
    AVG(f.sales_amount) as avg_transaction_value,
    MAX(d.full_date) as last_purchase_date,
    MIN(d.full_date) as first_purchase_date
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key AND c.is_current = TRUE
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY c.customer_key, c.customer_id, c.customer_segment, c.loyalty_tier;

CREATE INDEX idx_mv_ltv_customer ON mv_customer_ltv_summary(customer_key);
CREATE INDEX idx_mv_ltv_segment ON mv_customer_ltv_summary(customer_segment);

COMMENT ON MATERIALIZED VIEW mv_customer_ltv_summary IS 'Customer lifetime value metrics';

-- ============================================
-- Refresh materialized views
-- Use these commands periodically or in ETL
-- ============================================
-- REFRESH MATERIALIZED VIEW mv_monthly_sales_by_category;
-- REFRESH MATERIALIZED VIEW mv_customer_ltv_summary;

-- ============================================
-- Fact tables creation completed successfully
-- ============================================
