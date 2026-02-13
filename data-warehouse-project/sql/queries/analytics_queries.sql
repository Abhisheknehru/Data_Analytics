-- ============================================
-- Analytics Queries for Data Warehouse
-- ============================================
-- Author: Your Name
-- Date: February 2026
-- Description: Common analytical queries for business insights
-- ============================================

-- ============================================
-- 1. TOP SELLING PRODUCTS
-- ============================================
-- Description: Identify best-performing products by revenue
SELECT 
    p.product_name,
    p.brand,
    p.category_level_1,
    p.category_level_2,
    SUM(f.sales_amount) as total_revenue,
    SUM(f.quantity_sold) as total_units_sold,
    SUM(f.profit_amount) as total_profit,
    ROUND(AVG(f.unit_price), 2) as avg_selling_price,
    COUNT(DISTINCT f.transaction_id) as transaction_count
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
    AND p.is_current = TRUE
GROUP BY p.product_name, p.brand, p.category_level_1, p.category_level_2
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================
-- 2. CUSTOMER SEGMENTATION ANALYSIS
-- ============================================
-- Description: Analyze customer segments by profitability and behavior
SELECT 
    c.customer_segment,
    c.loyalty_tier,
    COUNT(DISTINCT c.customer_key) as customer_count,
    COUNT(DISTINCT f.transaction_id) as total_transactions,
    SUM(f.sales_amount) as total_revenue,
    SUM(f.profit_amount) as total_profit,
    AVG(f.sales_amount) as avg_transaction_value,
    ROUND(SUM(f.profit_amount) / NULLIF(SUM(f.sales_amount), 0) * 100, 2) as profit_margin_pct,
    ROUND(SUM(f.sales_amount) / COUNT(DISTINCT c.customer_key), 2) as revenue_per_customer
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
    AND c.is_current = TRUE
GROUP BY c.customer_segment, c.loyalty_tier
ORDER BY total_revenue DESC;

-- ============================================
-- 3. MONTHLY SALES TREND WITH YOY COMPARISON
-- ============================================
-- Description: Track sales trends with year-over-year growth
SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.sales_amount) as monthly_sales,
    SUM(f.profit_amount) as monthly_profit,
    SUM(f.quantity_sold) as units_sold,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    COUNT(DISTINCT f.transaction_id) as transaction_count,
    LAG(SUM(f.sales_amount)) OVER (PARTITION BY d.month ORDER BY d.year) as prev_year_sales,
    ROUND(
        ((SUM(f.sales_amount) - LAG(SUM(f.sales_amount)) OVER (PARTITION BY d.month ORDER BY d.year)) 
        / NULLIF(LAG(SUM(f.sales_amount)) OVER (PARTITION BY d.month ORDER BY d.year), 0)) * 100, 
        2
    ) as yoy_growth_pct
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year IN (2023, 2024)
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- ============================================
-- 4. STORE PERFORMANCE BY REGION
-- ============================================
-- Description: Compare store performance across different regions
SELECT 
    s.region,
    s.state,
    s.city,
    COUNT(DISTINCT s.store_key) as store_count,
    SUM(f.sales_amount) as total_sales,
    SUM(f.profit_amount) as total_profit,
    ROUND(AVG(f.sales_amount), 2) as avg_transaction_value,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    ROUND(SUM(f.sales_amount) / COUNT(DISTINCT s.store_key), 2) as sales_per_store,
    ROUND(SUM(f.profit_amount) / NULLIF(SUM(f.sales_amount), 0) * 100, 2) as profit_margin_pct
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY s.region, s.state, s.city
ORDER BY total_sales DESC;

-- ============================================
-- 5. PROMOTION EFFECTIVENESS ANALYSIS
-- ============================================
-- Description: Evaluate ROI and impact of promotional campaigns
SELECT 
    pr.promotion_name,
    pr.promotion_type,
    pr.discount_percentage,
    pr.start_date,
    pr.end_date,
    COUNT(DISTINCT f.transaction_id) as transaction_count,
    SUM(f.quantity_sold) as units_sold,
    SUM(f.sales_amount) as total_revenue,
    SUM(f.discount_amount) as total_discount_given,
    SUM(f.profit_amount) as total_profit,
    ROUND(SUM(f.profit_amount) / NULLIF(SUM(f.sales_amount), 0) * 100, 2) as profit_margin_pct,
    ROUND(SUM(f.sales_amount) / NULLIF(COUNT(DISTINCT f.transaction_id), 0), 2) as avg_transaction_value,
    COUNT(DISTINCT f.customer_key) as unique_customers
FROM fact_sales f
JOIN dim_promotion pr ON f.promotion_key = pr.promotion_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE pr.promotion_key != 0  -- Exclude non-promotional sales
    AND d.year = 2024
GROUP BY pr.promotion_name, pr.promotion_type, pr.discount_percentage, pr.start_date, pr.end_date
ORDER BY total_revenue DESC;

-- ============================================
-- 6. CUSTOMER LIFETIME VALUE (CLV)
-- ============================================
-- Description: Calculate customer lifetime value and purchase patterns
WITH customer_metrics AS (
    SELECT 
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.customer_segment,
        c.loyalty_tier,
        MIN(d.full_date) as first_purchase_date,
        MAX(d.full_date) as last_purchase_date,
        COUNT(DISTINCT f.transaction_id) as total_transactions,
        SUM(f.sales_amount) as lifetime_revenue,
        SUM(f.profit_amount) as lifetime_profit,
        AVG(f.sales_amount) as avg_transaction_value,
        SUM(f.quantity_sold) as total_units_purchased
    FROM fact_sales f
    JOIN dim_customer c ON f.customer_key = c.customer_key
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE c.is_current = TRUE
    GROUP BY c.customer_key, c.customer_id, c.first_name, c.last_name, 
             c.customer_segment, c.loyalty_tier
)
SELECT 
    customer_id,
    first_name || ' ' || last_name as customer_name,
    customer_segment,
    loyalty_tier,
    first_purchase_date,
    last_purchase_date,
    EXTRACT(DAY FROM (last_purchase_date - first_purchase_date)) as customer_age_days,
    total_transactions,
    ROUND(lifetime_revenue, 2) as lifetime_revenue,
    ROUND(lifetime_profit, 2) as lifetime_profit,
    ROUND(avg_transaction_value, 2) as avg_transaction_value,
    total_units_purchased,
    ROUND(lifetime_revenue / NULLIF(total_transactions, 0), 2) as avg_order_value,
    CASE 
        WHEN EXTRACT(DAY FROM (CURRENT_DATE - last_purchase_date)) > 180 THEN 'At Risk'
        WHEN EXTRACT(DAY FROM (CURRENT_DATE - last_purchase_date)) > 90 THEN 'Inactive'
        ELSE 'Active'
    END as customer_status
FROM customer_metrics
ORDER BY lifetime_revenue DESC
LIMIT 100;

-- ============================================
-- 7. PRODUCT CATEGORY PERFORMANCE
-- ============================================
-- Description: Hierarchical category analysis
SELECT 
    p.category_level_1,
    p.category_level_2,
    COUNT(DISTINCT p.product_key) as product_count,
    SUM(f.sales_amount) as total_revenue,
    SUM(f.profit_amount) as total_profit,
    SUM(f.quantity_sold) as units_sold,
    ROUND(AVG(f.unit_price), 2) as avg_selling_price,
    ROUND(SUM(f.profit_amount) / NULLIF(SUM(f.sales_amount), 0) * 100, 2) as profit_margin_pct,
    COUNT(DISTINCT f.customer_key) as unique_customers
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
    AND p.is_current = TRUE
GROUP BY p.category_level_1, p.category_level_2
ORDER BY total_revenue DESC;

-- ============================================
-- 8. DAY OF WEEK SALES PATTERN
-- ============================================
-- Description: Identify sales patterns by day of week
SELECT 
    d.day_of_week,
    d.day_of_week_num,
    COUNT(DISTINCT f.transaction_id) as transaction_count,
    SUM(f.sales_amount) as total_sales,
    AVG(f.sales_amount) as avg_transaction_value,
    SUM(f.quantity_sold) as total_units,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    ROUND(SUM(f.sales_amount) / COUNT(DISTINCT d.full_date), 2) as avg_daily_sales
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY d.day_of_week, d.day_of_week_num
ORDER BY d.day_of_week_num;

-- ============================================
-- 9. CUSTOMER RETENTION COHORT ANALYSIS
-- ============================================
-- Description: Track customer retention by cohort
WITH customer_cohorts AS (
    SELECT 
        c.customer_key,
        DATE_TRUNC('month', MIN(d.full_date)) as cohort_month
    FROM fact_sales f
    JOIN dim_customer c ON f.customer_key = c.customer_key
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY c.customer_key
),
cohort_activity AS (
    SELECT 
        cc.cohort_month,
        DATE_TRUNC('month', d.full_date) as activity_month,
        COUNT(DISTINCT f.customer_key) as active_customers
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    JOIN customer_cohorts cc ON f.customer_key = cc.customer_key
    GROUP BY cc.cohort_month, DATE_TRUNC('month', d.full_date)
)
SELECT 
    cohort_month,
    activity_month,
    active_customers,
    EXTRACT(MONTH FROM AGE(activity_month, cohort_month)) as months_since_first_purchase,
    ROUND(
        active_customers::NUMERIC / 
        FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY activity_month) * 100, 
        2
    ) as retention_rate
FROM cohort_activity
WHERE cohort_month >= '2024-01-01'
ORDER BY cohort_month, activity_month;

-- ============================================
-- 10. INVENTORY TURNOVER ANALYSIS
-- ============================================
-- Description: Calculate inventory metrics and turnover rates
WITH inventory_summary AS (
    SELECT 
        p.product_name,
        p.category_level_1,
        AVG(inv.quantity_on_hand) as avg_inventory,
        SUM(f.quantity_sold) as total_sold,
        AVG(inv.inventory_value) as avg_inventory_value
    FROM fact_product_inventory inv
    JOIN dim_product p ON inv.product_key = p.product_key
    JOIN dim_date d ON inv.date_key = d.date_key
    LEFT JOIN fact_sales f ON f.product_key = p.product_key 
        AND f.date_key = d.date_key
    WHERE d.year = 2024
        AND p.is_current = TRUE
    GROUP BY p.product_name, p.category_level_1
)
SELECT 
    product_name,
    category_level_1,
    ROUND(avg_inventory, 0) as avg_inventory_units,
    total_sold,
    ROUND(avg_inventory_value, 2) as avg_inventory_value,
    ROUND(total_sold / NULLIF(avg_inventory, 0), 2) as inventory_turnover_ratio,
    ROUND(365 / NULLIF(total_sold / NULLIF(avg_inventory, 0), 0), 0) as days_of_supply
FROM inventory_summary
WHERE avg_inventory > 0
ORDER BY inventory_turnover_ratio DESC
LIMIT 50;

-- ============================================
-- End of Analytics Queries
-- ============================================
