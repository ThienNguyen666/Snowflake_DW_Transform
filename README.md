# Customer Data Warehouse (Snowflake + dbt)

## Overview

This project implements an end-to-end ELT pipeline to build a production-ready data warehouse for analytical workloads.

The pipeline extracts data from SQL Server, loads it into Snowflake, and transforms it using dbt into a clean Star Schema with validated data quality and documented lineage.

---

## Architecture

SQL Server → Airbyte → Snowflake (RAW) → dbt → Staging → Dimensions / Fact → KPI Layer

---

## Tech Stack

- Data Source: SQL Server
- Ingestion: Airbyte
- Data Warehouse: Snowflake
- Transformation: dbt
- Modeling: Star Schema
- Data Quality: dbt tests
- Documentation: dbt docs

---

## Data Model

### Staging Layer
Standardizes raw data from Snowflake:
- stg_customer
- stg_person
- stg_product
- stg_sales

### Intermediate Layer
- stg_customer_enriched (join + deduplicate customer data)
- stg_product_hierarchy (category + subcategory)

### Marts Layer

#### Dimension Tables
- dim_customers
- dim_products

#### Fact Table
- fct_sales

### KPI Layer
- fct_sales_kpi (revenue, total orders, avg order value)

---

## Key Implementation Details

### 1. Handling Duplicate Data

Raw data ingested via Airbyte may contain multiple records per business key.

Resolved using window function:

```sql
row_number() over (
    partition by customerid
    order by _airbyte_extracted_at desc
)
```

Ensures one record per customer based on the latest ingestion timestamp.

---

### 2. Data Modeling

* Star Schema design for analytical queries
* Fact table stores transactional data
* Dimension tables provide descriptive context

---

### 3. Data Quality

dbt tests applied:

* not_null on primary fields
* unique on business keys

All tests pass after transformation.

---

### 4. Documentation & Lineage

Generated using:

```bash
dbt docs generate
dbt docs serve
```

Provides:

* Model-level documentation
* Column-level metadata
* Full data lineage graph

---

## Project Structure

```
models/
  staging/
  marts/
    dim/
    fact/
```

---

## How to Run

### 1. Configure dbt profile

Set in `~/.dbt/profiles.yml`:

* account
* user
* password
* role: DWH_ENGINEER_ROLE
* warehouse: CUSTOMER_WAREHOUSE
* database: CUSTOMER_BI
* schema: ANALYTICS_DWH

---

### 2. Run pipeline

```bash
dbt run
```

---

### 3. Run tests

```bash
dbt test
```

---

### 4. Generate docs

```bash
dbt docs generate
dbt docs serve
```

---

## Result

* Clean, analytics-ready data warehouse in Snowflake
* Star schema for efficient querying
* Data quality enforced via tests
* Fully documented data lineage

---

## What I Learned

* Designing layered data pipelines (staging → marts)
* Handling real-world data issues (duplicates from ingestion)
* Applying dbt for modular, testable transformations
* Building production-style data models

---

## Next Steps

* Implement SCD Type 2 for dimension tables
* Add dashboard layer (Power BI / Tableau)
* Automate pipeline with orchestration (Airflow)

