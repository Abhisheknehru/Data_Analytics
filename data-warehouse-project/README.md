# 📊 Data Warehouse for Customer and Product Analytics

A comprehensive data warehouse solution implementing a **Star Schema** architecture for customer and product analytics. This project demonstrates end-to-end data warehouse design, ETL implementation, and analytics capabilities.

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Database](https://img.shields.io/badge/database-PostgreSQL-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 🎯 Project Overview

This project implements a production-ready data warehouse using dimensional modeling techniques to support:
- Customer behavior analysis
- Product performance tracking
- Sales trend analysis
- Promotion effectiveness measurement
- Regional performance monitoring

## 🏗️ Architecture

### Star Schema Design
```
                    Dim_Date
                       |
    Dim_Customer --- Fact_Sales --- Dim_Product
                       |
                   Dim_Store
                       |
                  Dim_Promotion
```

The warehouse consists of:
- **1 Fact Table**: `fact_sales` (transactional sales data)
- **5 Dimension Tables**: Customer, Product, Store, Date, Promotion
- **Slowly Changing Dimensions**: Type 2 implementation for Customer and Product

## 📁 Project Structure

```
data-warehouse-project/
├── README.md                 # Project overview and documentation
├── requirements.txt          # Python dependencies
├── .gitignore               # Git ignore rules
├── LICENSE                  # MIT License
│
├── sql/                     # SQL scripts
│   ├── schema/
│   │   ├── create_dimensions.sql
│   │   ├── create_facts.sql
│   │   └── create_indexes.sql
│   ├── sample_data/
│   │   └── insert_sample_data.sql
│   └── queries/
│       ├── analytics_queries.sql
│       └── performance_queries.sql
│
├── scripts/                 # Python ETL scripts
│   ├── etl/
│   │   ├── extract.py
│   │   ├── transform.py
│   │   ├── load.py
│   │   └── scd_handler.py
│   ├── utils/
│   │   ├── db_connector.py
│   │   ├── logger.py
│   │   └── validators.py
│   └── generate_sample_data.py
│
├── config/                  # Configuration files
│   ├── database_config.yaml
│   └── etl_config.yaml
│
├── notebooks/               # Jupyter notebooks for analysis
│   ├── 01_data_exploration.ipynb
│   ├── 02_sales_analysis.ipynb
│   └── 03_customer_segmentation.ipynb
│
├── data/                    # Sample data files
│   ├── raw/
│   └── processed/
│
├── docs/                    # Documentation
│   ├── architecture.md
│   ├── etl_process.md
│   ├── data_dictionary.md
│   └── deployment_guide.md
│
└── tests/                   # Unit tests
    ├── test_etl.py
    └── test_validators.py
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- PostgreSQL 12+ (or any SQL database)
- pip package manager

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/data-warehouse-project.git
cd data-warehouse-project
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure database connection**
```bash
cp config/database_config.yaml.example config/database_config.yaml
# Edit the file with your database credentials
```

4. **Create database schema**
```bash
psql -U your_username -d your_database -f sql/schema/create_dimensions.sql
psql -U your_username -d your_database -f sql/schema/create_facts.sql
psql -U your_username -d your_database -f sql/schema/create_indexes.sql
```

5. **Generate and load sample data**
```bash
python scripts/generate_sample_data.py
python scripts/etl/load.py
```

## 📊 Database Schema

### Fact Table: fact_sales
Primary transactional table containing sales metrics:
- sales_key (PK)
- date_key, customer_key, product_key, store_key, promotion_key (FKs)
- Measures: quantity_sold, sales_amount, cost_amount, profit_amount, etc.

### Dimension Tables

| Dimension | Key Attributes | SCD Type |
|-----------|---------------|----------|
| dim_customer | customer_segment, loyalty_tier, demographics | Type 2 |
| dim_product | category hierarchy, brand, pricing | Type 2 |
| dim_store | location, region, store_type | Type 1 |
| dim_date | calendar attributes, fiscal periods | Static |
| dim_promotion | promotion_type, discount_percentage | Type 1 |

## 💡 Key Features

### ✅ Implemented Features
- ✓ Complete star schema with normalized dimensions
- ✓ Slowly Changing Dimension (Type 2) handling
- ✓ Comprehensive ETL pipeline
- ✓ Data quality validation
- ✓ Sample data generation
- ✓ Performance optimization (indexes, partitioning)
- ✓ Analytical query examples
- ✓ Documentation and data dictionary

### 📈 Analytics Capabilities
- Customer lifetime value analysis
- Product performance tracking
- Sales trend analysis (daily, monthly, yearly)
- Customer segmentation
- Promotion effectiveness
- Regional performance comparison
- Year-over-year growth analysis

## 🔍 Sample Queries

### Top Selling Products
```sql
SELECT 
    p.product_name,
    p.category_level_1,
    SUM(f.sales_amount) as total_revenue,
    SUM(f.quantity_sold) as units_sold
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024 AND p.is_current = TRUE
GROUP BY p.product_name, p.category_level_1
ORDER BY total_revenue DESC
LIMIT 10;
```

### Customer Segmentation Analysis
```sql
SELECT 
    c.customer_segment,
    COUNT(DISTINCT c.customer_key) as customer_count,
    AVG(f.sales_amount) as avg_transaction_value,
    SUM(f.profit_amount) as total_profit
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.is_current = TRUE
GROUP BY c.customer_segment
ORDER BY total_profit DESC;
```

More queries available in `sql/queries/analytics_queries.sql`

## 🛠️ ETL Pipeline

The ETL process follows these steps:

1. **Extract**: Pull data from source systems (CSV, API, databases)
2. **Transform**: 
   - Data cleansing and validation
   - Type conversions
   - Business rule application
   - SCD Type 2 processing
3. **Load**: Bulk insert to staging, then to warehouse tables

```bash
# Run the complete ETL pipeline
python scripts/etl/extract.py
python scripts/etl/transform.py
python scripts/etl/load.py
```

## 📈 Performance Optimization

### Indexing Strategy
- Primary keys on all tables
- Foreign keys in fact tables
- Commonly filtered columns (date, customer_segment, category)

### Partitioning
- Fact tables partitioned by date (monthly)
- Improves query performance for time-based analysis

### Materialized Views
Pre-aggregated summaries for common queries:
- Monthly sales summary
- Customer segment aggregates
- Product category rollups

## 🧪 Testing

Run unit tests:
```bash
python -m pytest tests/
```

## 📚 Documentation

Detailed documentation available in the `docs/` folder:
- [Architecture Overview](docs/architecture.md)
- [ETL Process](docs/etl_process.md)
- [Data Dictionary](docs/data_dictionary.md)
- [Deployment Guide](docs/deployment_guide.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Star Schema design based on Ralph Kimball's dimensional modeling methodology
- Inspired by real-world data warehouse implementations

## 📞 Support

For support, email your.email@example.com or open an issue in the GitHub repository.

---

**⭐ If you find this project helpful, please consider giving it a star!**
