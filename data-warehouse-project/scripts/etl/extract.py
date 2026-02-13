"""
ETL Extract Module
==================
Extracts data from source systems (CSV, Database, API)
Author: Your Name
Date: February 2026
"""

import pandas as pd
import psycopg2
import logging
from datetime import datetime
from pathlib import Path
import yaml
import requests
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/extract.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class DataExtractor:
    """
    Handles extraction of data from various source systems
    """
    
    def __init__(self, config_path='config/etl_config.yaml'):
        """Initialize extractor with configuration"""
        self.config = self._load_config(config_path)
        self.extract_timestamp = datetime.now()
        self.staging_path = Path('data/staging')
        self.staging_path.mkdir(parents=True, exist_ok=True)
        
    def _load_config(self, config_path):
        """Load configuration from YAML file"""
        try:
            with open(config_path, 'r') as f:
                return yaml.safe_load(f)
        except Exception as e:
            logger.error(f"Error loading config: {e}")
            raise
    
    def extract_from_csv(self, file_path, entity_name):
        """
        Extract data from CSV file
        
        Args:
            file_path: Path to CSV file
            entity_name: Name of the entity (e.g., 'customers', 'products')
        
        Returns:
            pandas DataFrame
        """
        try:
            logger.info(f"Extracting {entity_name} from CSV: {file_path}")
            df = pd.read_csv(file_path)
            
            # Add metadata
            df['extract_timestamp'] = self.extract_timestamp
            df['source_system'] = 'CSV'
            
            # Save to staging
            staging_file = self.staging_path / f"{entity_name}_{self.extract_timestamp.strftime('%Y%m%d_%H%M%S')}.csv"
            df.to_csv(staging_file, index=False)
            
            logger.info(f"Extracted {len(df)} records for {entity_name}")
            return df
            
        except Exception as e:
            logger.error(f"Error extracting from CSV {file_path}: {e}")
            raise
    
    def extract_from_database(self, query, entity_name, db_config=None):
        """
        Extract data from source database
        
        Args:
            query: SQL query to extract data
            entity_name: Name of the entity
            db_config: Database configuration (optional, uses config file if not provided)
        
        Returns:
            pandas DataFrame
        """
        if db_config is None:
            db_config = self.config.get('source_database', {})
        
        try:
            logger.info(f"Extracting {entity_name} from database")
            
            # Connect to source database
            conn = psycopg2.connect(
                host=db_config.get('host'),
                port=db_config.get('port', 5432),
                database=db_config.get('database'),
                user=db_config.get('user'),
                password=db_config.get('password')
            )
            
            # Extract data
            df = pd.read_sql_query(query, conn)
            conn.close()
            
            # Add metadata
            df['extract_timestamp'] = self.extract_timestamp
            df['source_system'] = 'Database'
            
            # Save to staging
            staging_file = self.staging_path / f"{entity_name}_{self.extract_timestamp.strftime('%Y%m%d_%H%M%S')}.csv"
            df.to_csv(staging_file, index=False)
            
            logger.info(f"Extracted {len(df)} records for {entity_name}")
            return df
            
        except Exception as e:
            logger.error(f"Error extracting from database: {e}")
            raise
    
    def extract_from_api(self, endpoint, entity_name, params=None, headers=None):
        """
        Extract data from REST API
        
        Args:
            endpoint: API endpoint URL
            entity_name: Name of the entity
            params: Query parameters (optional)
            headers: Request headers (optional)
        
        Returns:
            pandas DataFrame
        """
        try:
            logger.info(f"Extracting {entity_name} from API: {endpoint}")
            
            response = requests.get(endpoint, params=params, headers=headers)
            response.raise_for_status()
            
            data = response.json()
            
            # Convert to DataFrame
            if isinstance(data, list):
                df = pd.DataFrame(data)
            elif isinstance(data, dict) and 'data' in data:
                df = pd.DataFrame(data['data'])
            else:
                df = pd.DataFrame([data])
            
            # Add metadata
            df['extract_timestamp'] = self.extract_timestamp
            df['source_system'] = 'API'
            
            # Save to staging
            staging_file = self.staging_path / f"{entity_name}_{self.extract_timestamp.strftime('%Y%m%d_%H%M%S')}.csv"
            df.to_csv(staging_file, index=False)
            
            logger.info(f"Extracted {len(df)} records for {entity_name}")
            return df
            
        except Exception as e:
            logger.error(f"Error extracting from API {endpoint}: {e}")
            raise
    
    def extract_incremental(self, query, entity_name, last_extract_date, date_column='updated_at'):
        """
        Extract incremental data (only changed records since last extract)
        
        Args:
            query: Base SQL query
            entity_name: Name of the entity
            last_extract_date: Last extraction date
            date_column: Column name for filtering (default: 'updated_at')
        
        Returns:
            pandas DataFrame
        """
        try:
            # Add WHERE clause for incremental extraction
            incremental_query = f"""
                {query}
                WHERE {date_column} > '{last_extract_date}'
            """
            
            logger.info(f"Extracting incremental data for {entity_name} since {last_extract_date}")
            return self.extract_from_database(incremental_query, entity_name)
            
        except Exception as e:
            logger.error(f"Error in incremental extraction: {e}")
            raise
    
    def get_extraction_metadata(self):
        """
        Get metadata about the extraction process
        
        Returns:
            dict with extraction metadata
        """
        return {
            'extract_timestamp': self.extract_timestamp,
            'staging_path': str(self.staging_path),
            'config': self.config
        }


def main():
    """Main extraction process"""
    try:
        logger.info("=" * 50)
        logger.info("Starting Data Extraction Process")
        logger.info("=" * 50)
        
        extractor = DataExtractor()
        
        # Example: Extract customers from CSV
        customers_df = extractor.extract_from_csv(
            file_path='data/raw/customers.csv',
            entity_name='customers'
        )
        
        # Example: Extract products from database
        products_query = """
            SELECT 
                product_id,
                product_name,
                category,
                price,
                cost,
                updated_at
            FROM products
            WHERE is_active = TRUE
        """
        # products_df = extractor.extract_from_database(products_query, 'products')
        
        # Example: Extract sales from API
        # sales_df = extractor.extract_from_api(
        #     endpoint='https://api.example.com/sales',
        #     entity_name='sales',
        #     params={'start_date': '2024-01-01', 'end_date': '2024-12-31'}
        # )
        
        logger.info("=" * 50)
        logger.info("Data Extraction Completed Successfully")
        logger.info("=" * 50)
        
        # Print metadata
        metadata = extractor.get_extraction_metadata()
        logger.info(f"Extract Timestamp: {metadata['extract_timestamp']}")
        logger.info(f"Staging Path: {metadata['staging_path']}")
        
    except Exception as e:
        logger.error(f"Extraction process failed: {e}")
        raise


if __name__ == "__main__":
    main()
