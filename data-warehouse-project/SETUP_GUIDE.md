# Quick Start Guide

## 🚀 Getting Your Data Warehouse Up and Running

This guide will help you set up and run the data warehouse project in under 30 minutes.

---

## Prerequisites

Before you begin, ensure you have:
- [ ] Python 3.8 or higher installed
- [ ] PostgreSQL 12+ (or access to a PostgreSQL database)
- [ ] Git installed
- [ ] 1GB free disk space

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/data-warehouse-project.git
cd data-warehouse-project
```

---

## Step 2: Set Up Python Environment

### Option A: Using venv (Recommended)
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Option B: Using conda
```bash
conda create -n dw-env python=3.10
conda activate dw-env
pip install -r requirements.txt
```

---

## Step 3: Database Setup

### Create PostgreSQL Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE data_warehouse;

# Create user (optional)
CREATE USER dw_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE data_warehouse TO dw_user;

# Exit PostgreSQL
\q
```

---

## Step 4: Configure Database Connection

Create a configuration file:

```bash
cp config/database_config.yaml.example config/database_config.yaml
```

Edit `config/database_config.yaml` with your database credentials:

```yaml
warehouse_database:
  host: localhost
  port: 5432
  database: data_warehouse
  user: dw_user
  password: your_password
```

---

## Step 5: Create Database Schema

Run the SQL scripts to create tables:

```bash
# Create dimension tables
psql -U dw_user -d data_warehouse -f sql/schema/create_dimensions.sql

# Create fact tables
psql -U dw_user -d data_warehouse -f sql/schema/create_facts.sql

# Create indexes (optional but recommended)
psql -U dw_user -d data_warehouse -f sql/schema/create_indexes.sql
```

**Expected output**: You should see `CREATE TABLE` messages for each table created.

---

## Step 6: Generate Sample Data

Generate realistic sample data for testing:

```bash
python scripts/generate_sample_data.py
```

**Expected output**:
```
Generating Date Dimension...
✓ Generated 2,557 date records
Generating Customer Dimension...
✓ Generated 5,000 customer records
Generating Product Dimension...
✓ Generated 500 product records
...
✅ Sample data generation completed successfully!
```

---

## Step 7: Load Data into Warehouse

Load the generated data:

```bash
# Load dimension data first
python scripts/etl/load_dimensions.py

# Load fact data
python scripts/etl/load_facts.py
```

---

## Step 8: Verify Installation

Run a simple query to verify everything works:

```bash
psql -U dw_user -d data_warehouse
```

```sql
-- Check record counts
SELECT 'dim_date' as table_name, COUNT(*) as record_count FROM dim_date
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;
```

**Expected output**: You should see record counts for each table.

---

## Step 9: Run Analytics Queries

Try some analytics queries:

```sql
-- Top 10 Products by Revenue
SELECT 
    p.product_name,
    p.category_level_1,
    SUM(f.sales_amount) as total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024 AND p.is_current = TRUE
GROUP BY p.product_name, p.category_level_1
ORDER BY total_revenue DESC
LIMIT 10;
```

More queries available in `sql/queries/analytics_queries.sql`

---

## Step 10: Explore with Jupyter (Optional)

Start Jupyter to explore the data:

```bash
jupyter notebook notebooks/
```

Open `02_sales_analysis.ipynb` to see example analyses.

---

## 🎉 Congratulations!

Your data warehouse is now up and running! 

### What's Next?

1. **Customize the Schema**: Modify tables to match your business needs
2. **Connect BI Tools**: Link Tableau, Power BI, or other visualization tools
3. **Schedule ETL Jobs**: Set up automated data refreshes
4. **Add More Data**: Load your own data sources

---

## Common Issues & Solutions

### Issue: "psql: command not found"
**Solution**: Add PostgreSQL to your PATH or use full path:
```bash
/Library/PostgreSQL/14/bin/psql -U postgres  # Mac
"C:\Program Files\PostgreSQL\14\bin\psql.exe" -U postgres  # Windows
```

### Issue: "ModuleNotFoundError: No module named 'pandas'"
**Solution**: Ensure virtual environment is activated and dependencies installed:
```bash
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

### Issue: Database connection refused
**Solution**: Ensure PostgreSQL is running:
```bash
# Mac
brew services start postgresql@14

# Linux
sudo systemctl start postgresql

# Windows
# Start PostgreSQL service from Services app
```

### Issue: Permission denied
**Solution**: Grant proper permissions:
```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dw_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dw_user;
```

---

## Directory Structure Quick Reference

```
data-warehouse-project/
├── sql/schema/          # Database DDL scripts
├── sql/queries/         # Analytics queries
├── scripts/etl/         # ETL Python scripts
├── scripts/             # Utility scripts
├── data/raw/           # Sample data files
├── config/             # Configuration files
├── notebooks/          # Jupyter notebooks
└── docs/              # Documentation
```

---

## Useful Commands

```bash
# Activate environment
source venv/bin/activate

# Run tests
pytest tests/

# Generate new sample data
python scripts/generate_sample_data.py

# Connect to database
psql -U dw_user -d data_warehouse

# View logs
tail -f logs/etl.log

# Deactivate environment
deactivate
```

---

## Support

- **Documentation**: Check the `docs/` folder for detailed guides
- **Issues**: Open an issue on GitHub
- **Questions**: Check existing issues or discussions

---

**Last Updated**: February 2026  
**Version**: 1.0
