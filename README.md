# Customer Data Warehouse

## Overview

This project builds a production-ready data warehouse for analytical workloads, designed around a Customer Business Intelligence use case. The pipeline ingests transactional data from SQL Server, loads it into Snowflake, and transforms it using dbt into a clean Star Schema optimized for reporting and decision support.

The architecture follows the modern ELT pattern, separating ingestion concerns from transformation logic to maximize maintainability and scalability.

---

## Architecture

```
SQL Server  →  Airbyte  →  Snowflake (STAGING_AREA)  →  dbt  →  Staging  →  Marts  →  KPI Layer
```

Each layer has a distinct responsibility: raw ingestion, standardization, dimensional modeling, and aggregation. This separation makes the pipeline easy to test, debug, and extend.

---

## Tech Stack

| Component | Tool |
|---|---|
| Data Source | SQL Server (AdventureWorks) |
| Ingestion | Airbyte |
| Data Warehouse | Snowflake |
| Transformation | dbt (Data Build Tool) |
| Data Modeling | Star Schema |
| Data Quality | dbt generic tests |
| Documentation | dbt docs |

---

## Data Model

### Raw Layer (STAGING_AREA)

Tables and views ingested directly from SQL Server via Airbyte, stored as-is in the `STAGING_AREA` schema of the `CUSTOMER_BI` database. This layer is never modified after load.

Source tables: `CUSTOMER`, `PERSON`, `PRODUCT`, `PRODUCTCATEGORY`, `PRODUCTSUBCATEGORY`, `SALESORDERDETAIL`, `SALESORDERHEADER`

Source views: `VINDIVIDUALCUSTOMER`, `VPERSONDEMOGRAPHICS`

### Staging Layer

Standardizes raw source tables into clean, typed, consistently named models:

- `stg_customer` — base customer records from the CUSTOMER table
- `stg_person` — name fields from the PERSON table
- `stg_product` — product attributes including subcategory reference
- `stg_sales` — joined sales order header and detail into a single flat model

### Intermediate Layer

Enrichment and deduplication logic that sits between staging and the mart layer:

- `stg_customer_enriched` — joins customer, person, individual customer view, and demographics view; deduplicates on `customerid` using a window function
- `stg_product_hierarchy` — resolves the full product category chain by joining product, subcategory, and category

### Marts Layer

#### Dimension Tables

- `dim_customers` — customer attributes: name, location, demographics (gender, education, occupation, income)
- `dim_products` — product attributes: name, category, subcategory, cost, list price
- `dim_time` — date spine from 2010 to ~2026; provides date, year, quarter, month, week, day-of-week, and weekend flag attributes

#### Fact Table

- `fct_sales` — transactional grain; one row per order line; foreign keys to `dim_customers`, `dim_products`, and `dim_time`; measures are `orderqty`, `unitprice`, and `linetotal`

### KPI Layer

- `fct_sales_kpi` — pre-aggregated view grouped by year, month, and month name; exposes `revenue`, `total_orders`, and `avg_order_value` for direct use in dashboards and reports

---

## Key Implementation Details

### Handling Duplicate Records from Ingestion

Airbyte's full-refresh sync can produce multiple records for the same business key across incremental loads. This is resolved in `stg_customer_enriched` using a window function that retains only the most recent record per customer:

```sql
row_number() over (
    partition by customerid
    order by customerid
) as rn
```

Only rows where `rn = 1` are passed downstream, ensuring one canonical record per customer in all mart and KPI models.

### Star Schema Design

The mart layer follows a classic Star Schema pattern. `fct_sales` holds all transactional measures and references three dimension tables via surrogate or natural keys. `dim_time` is generated from a date spine rather than loaded from source, ensuring completeness across the entire analysis window regardless of transaction coverage.

This design keeps analytical queries simple (single-level joins) and fast, while dimension tables provide rich descriptive context for slicing and filtering.

### Data Quality with dbt Tests

Generic dbt tests are applied to primary keys across all mart models:

- `not_null` on all primary key columns
- `unique` on `customerid` (dim_customers), `productid` (dim_products), and `date_key` (dim_time)
- `not_null` on `salesorderid` (fct_sales)

All tests pass cleanly after deduplication is applied in the intermediate layer.

### Documentation and Lineage

dbt auto-generates model-level documentation, column-level metadata, and a full DAG lineage graph:

```bash
dbt docs generate
dbt docs serve
```

The lineage graph traces every model from raw source tables through to the KPI layer, making it easy to understand data dependencies and debug issues.

---

## Project Structure

```
models/
  staging/
    stg_customer.sql
    stg_customer_enriched.sql
    stg_person.sql
    stg_product.sql
    stg_product_hierarchy.sql
    stg_sales.sql
    schema.yml
  marts/
    dim_customers.sql
    dim_products.sql
    dim_time.sql
    fct_sales.sql
    fct_sales_kpi.sql
    schema.yml
```

---

## Setup and Configuration

### 1. Configure dbt profile

Add the following to `~/.dbt/profiles.yml`:

```yaml
customer_dwh:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account>
      user: <your_user>
      password: <your_password>
      role: DWH_ENGINEER_ROLE
      warehouse: CUSTOMER_WAREHOUSE
      database: CUSTOMER_BI
      schema: ANALYTICS_DWH
```

### 2. Run the pipeline

```bash
dbt run
```

### 3. Run data quality tests

```bash
dbt test
```

### 4. Generate and serve documentation

```bash
dbt docs generate
dbt docs serve
```

---

## Results

The pipeline produces a fully tested, documented, analytics-ready data warehouse in Snowflake. The Star Schema structure supports efficient slice-and-dice queries across customer, product, and time dimensions. All data quality constraints are enforced at the mart layer, and full lineage from raw source to final KPI table is visible in the dbt docs UI.

---

## What This Project Covers

- Layered ELT pipeline design: raw ingestion, staging, intermediate enrichment, dimensional modeling, and KPI aggregation
- Handling real-world ingestion issues: deduplication of records produced by full-refresh Airbyte syncs
- Modular, testable SQL transformations with dbt
- Star Schema dimensional modeling with a programmatically generated time dimension
- Data quality enforcement through dbt generic tests
- Full automated documentation and lineage tracking

---

## Next Steps

- Implement SCD Type 2 on dimension tables to track historical changes in customer and product attributes
- Add an orchestration layer (Airflow or dbt Cloud) to schedule and monitor pipeline runs
- Connect a BI front-end (Power BI or Tableau) directly to the KPI and mart layers
