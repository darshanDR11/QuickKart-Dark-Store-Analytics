
# QuickKart — Data Quality Report & Cleaning Documentation

## 1. Introduction

This document describes the data quality issues identified in the original QuickKart Dark-Store dataset and the techniques used to clean and prepare the data for analysis.

The cleaning process was implemented using Python and Pandas. It includes schema validation, text standardization, missing-value handling, data type conversion, duplicate removal, and business-rule-based record filtering.

### 1.1 Dataset Overview

| Metric | Value |
|---|---:|
| Total Tables | 6 |
| Total Original Records | 2,444,185 |
| Total Cleaned Records | 2,436,753 |
| Programming Language | Python |
| Main Library | Pandas |
| Numerical Library | NumPy |

### 1.2 Cleaning Workflow

The data cleaning process follows this sequence:

1. Load the original CSV datasets.
2. Validate the required columns.
3. Standardize text values.
4. Handle missing-value representations.
5. Convert columns to appropriate data types.
6. Identify and remove exact duplicate records.
7. Apply table-specific validation rules.
8. Remove invalid orders and associated order items.
9. Export the cleaned datasets as CSV files.

### 1.3 Python Libraries

```python
import pandas as pd
import numpy as np

from pathlib import Path
import time
import logging
from functools import wraps
```

| Library | Purpose |
|---|---|
| Pandas | Data loading, manipulation, cleaning, and filtering |
| NumPy | Missing-value representation using `np.nan` |
| Pathlib | File and directory path management |
| Time | Measuring function execution time |
| Logging | Recording pipeline execution and errors |
| Functools | Preserving function metadata when using decorators |

---

# 2. Dimension Tables

Dimension tables contain descriptive information used to categorize and analyze business transactions.

The three dimension tables in this project are:

- `products`
- `stores`
- `riders`

## 2.1 Products

### Table Overview

| Metric | Value |
|---|---:|
| Total Original Rows | 2,500 |
| Total Columns | 7 |
| Duplicate Rows | 0 |
| Duplicate Percentage | 0% |

### Column Profiling

| Column Name | Pandas Data Type | Logical Type | Null Values | Unique Values |
|---|---|---|---:|---:|
| `sku_id` | object | Text | 0 | 2,500 |
| `sku_name` | object | Text | 0 | 2,423 |
| `category` | object | Text | 0 | 10 |
| `sub_category` | object | Text | 0 | 34 |
| `brand` | object | Text | 0 | 20 |
| `mrp` | float64 | Number | 0 | 384 |
| `shelf_life_days` | int64 | Number | 0 | 8 |

### Issues Identified

**Issue 1 — Repeated Product Names**

- The table contains 2,500 product records but only 2,423 unique product names.
- Some products share the same name across different SKU identifiers.
- This is not necessarily a data quality error because different product variants or pack sizes may have similar names.

**Issue 2 — No Missing Values or Exact Duplicates**

- No missing values were identified.
- No exact duplicate rows were found.
- All 2,500 SKU identifiers are unique.

### Cleaning Technique

No product-specific records needed to be removed.

The following standard transformations were applied:

- Trim leading and trailing whitespace.
- Convert text fields to uppercase.
- Convert numeric fields to numeric data types.
- Remove exact duplicate rows.

### Python Code Used

```python
products = load_dataset('products.csv')
```

The generic `load_dataset()` function performs the cleaning operations.

**Result:** The products table remained unchanged in size.

| Metric | Before Cleaning | After Cleaning |
|---|---:|---:|
| Rows | 2,500 | 2,500 |
| Columns | 7 | 7 |

---

## 2.2 Stores

### Table Overview

| Metric | Value |
|---|---:|
| Total Original Rows | 40 |
| Total Columns | 5 |
| Duplicate Rows | 0 |
| Duplicate Percentage | 0% |

### Column Profiling

| Column Name | Pandas Data Type | Logical Type | Null Values (Before) | Unique Values (Before) | Null Values (After) | Unique Values (After) |
|---|---|---|---:|---:|---:|---:|
| `store_id` | object | Text | 0 | 40 | 0 | 40 |
| `city` | object | Text | 0 | 9 | 0 | 6 |
| `zone` | object | Text | 0 | 5 | 0 | 5 |
| `opening_date` | object | Date/Time | 0 | 38 | 0 | 38 |
| `parent_hub_id` | object | Text | 6 | 6 | 6 | 6 |

### Issues Identified

**Issue 1 — Inconsistent City Names**

The `city` column contained inconsistent casing and leading/trailing whitespace.

Examples:

| Original Value | Standardized Value |
|---|---|
| ` ahmedabad` | `AHMEDABAD` |
| `Ahmedabad` | `AHMEDABAD` |
| `Bengaluru` | `BENGALURU` |
| `Mumbai` | `MUMBAI` |
| `Pune` | `PUNE` |
| `SURAT ` | `SURAT` |
| `Surat` | `SURAT` |
| `Vadodara` | `VADODARA` |
| `pune` | `PUNE` |

The inconsistencies increased the number of unique city values to 9, even though the dataset represents 6 cities.

**Issue 2 — Missing Parent Hub IDs**

- The `parent_hub_id` column contains 6 missing values.
- These missing values were retained.
- No replacement value was assigned because the actual parent hub could not be determined from the available data.

### Cleaning Technique

1. Remove leading and trailing whitespace.
2. Convert city names to a consistent uppercase format.
3. Normalize blank and common missing-value strings.
4. Convert `opening_date` into datetime format.
5. Preserve existing missing `parent_hub_id` values.

### Python Code Used

```python
stores = load_dataset('stores.csv')
```

The text standardization is performed by:

```python
for col in text_columns:
    df[col] = df[col].str.strip().str.upper()
    df[col] = df[col].replace(
        ['', 'NA', 'N/A', 'na', 'n/a'],
        np.nan
    )
```

### Result

| Metric | Before Cleaning | After Cleaning |
|---|---:|---:|
| Rows | 40 | 40 |
| Columns | 5 | 5 |
| Unique Cities | 9 | 6 |
| Missing Parent Hub IDs | 6 | 6 |

**Note:** The actual script standardizes city names to uppercase, not title case. The final unique city count is 6.

---

## 2.3 Riders

### Table Overview

| Metric | Value |
|---|---:|
| Total Original Rows | 1,200 |
| Total Columns | 5 |
| Duplicate Rows | 0 |
| Duplicate Percentage | 0% |

### Column Profiling

| Column Name | Pandas Data Type | Logical Type | Null Values | Unique Values |
|---|---|---|---:|---:|
| `rider_id` | object | Text | 0 | 1,200 |
| `store_id` | object | Text | 0 | 40 |
| `join_date` | object | Date/Time | 0 | 568 |
| `shift` | object | Text | 0 | 3 |
| `vehicle_type` | object | Text | 30 | 3 |

### Issues Identified

**Issue 1 — Invalid Missing-Value Representation in Vehicle Type**

- The `vehicle_type` column contains 30 records with the literal string `"NA"`.
- These values represent missing information but are stored as text.
- This can incorrectly affect unique-value counts and categorical analysis.

### Cleaning Technique

Replace literal missing-value strings with proper Pandas null values.

The transformation also standardizes text and trims whitespace.

### Python Code Used

```python
riders = load_dataset('riders.csv')
```

The missing-value conversion is handled by:

```python
df[col] = df[col].str.strip().str.upper()

df[col] = df[col].replace(
    ['', 'NA', 'N/A', 'na', 'n/a'],
    np.nan
)
```

### Result

| Metric | Before Cleaning | After Cleaning |
|---|---:|---:|
| Rows | 1,200 | 1,200 |
| Columns | 5 | 5 |
| Missing Vehicle Type Values | 30 | 30 |

The 30 missing values remain missing, but their representation is standardized as `NaN`.

---

# 3. Inventory Fact Table

## 3.1 Daily Stock Snapshot

### Table Overview

| Metric | Value |
|---|---:|
| Total Original Rows | 876,800 |
| Total Columns | 5 |
| Duplicate Rows | 0 |
| Duplicate Percentage | 0% |

### Column Profiling

| Column Name | Pandas Data Type | Logical Type | Null Values | Unique Values |
|---|---|---|---:|---:|
| `snapshot_date` | object | Date/Time | 0 | 548 |
| `store_id` | object | Text | 0 | 40 |
| `sku_id` | object | Text | 0 | 40 |
| `closing_qty` | int64 | Number | 0 | 151 |
| `received_qty` | int64 | Number | 0 | 132 |

### Issues Identified

**Issue 1 — Limited SKU Coverage**

- Only 40 unique `sku_id` values are present in the stock snapshot table.
- The products master table contains 2,500 unique SKU identifiers.
- This indicates that the stock snapshot data covers only a subset of the product catalogue.

This is a coverage observation, not automatically an invalid-record issue.

**Issue 2 — No Missing Values or Exact Duplicates**

- No missing values were found.
- No exact duplicate records were found.
- All columns have valid values according to the supplied profiling report.

### Cleaning Technique

No table-specific records were removed.

The following standard transformations were applied:

- Convert `snapshot_date` into datetime format.
- Standardize `store_id` and `sku_id` text values.
- Convert `closing_qty` and `received_qty` into numeric data types.
- Check for exact duplicate rows.

### Python Code Used

```python
daily_stock_snapshot = load_dataset(
    'daily_stock_snapshot.csv'
)
```

### Result

| Metric | Before Cleaning | After Cleaning |
|---|---:|---:|
| Rows | 876,800 | 876,800 |
| Columns | 5 | 5 |
| Duplicate Rows | 0 | 0 |

No records were removed from this table.

---

# 4. Transaction Fact Tables

Transaction fact tables contain order-level and order-item-level information.

The two tables are:

- `orders`
- `order_items`

These tables required the most significant data quality corrections because their records are related through `order_id`.

## 4.1 Orders

### Table Overview

| Metric | Value |
|---|---:|
| Total Original Rows | 400,600 |
| Total Columns | 9 |
| Exact Duplicate Rows | 589 |
| Duplicate Percentage | 0.15% |
| Unique Order IDs Before Cleaning | 400,000 |

### Column Profiling

| Column Name | Pandas Data Type | Logical Type | Null Values | Unique Values |
|---|---|---|---:|---:|
| `order_id` | object | Text | 0 | 400,000 |
| `customer_id` | object | Text | 0 | 44,733 |
| `store_id` | object | Text | 0 | 40 |
| `order_ts` | object | Date/Time | 0 | 397,362 |
| `rider_id` | object | Text | 0 | 1,200 |
| `delivered_ts` | object | Date/Time | 24,234 | 373,508 |
| `promised_mins` | int64 | Number | 0 | 1 |
| `status` | object | Text | 0 | 3 |
| `payment_mode` | object | Text | 2,696 | 4 |

### Issues Identified

#### Issue 1 — Exact Duplicate Records

- 589 exact duplicate rows were found.
- These records were identical across all columns.
- Keeping them would cause duplicate records in the order-level analysis.

**Solution:** Remove exact duplicate rows using `drop_duplicates()`.

#### Issue 2 — Repeated Order IDs With Conflicting Values

After removing exact duplicate rows:

- 400,011 records remained.
- 11 `order_id` values were still repeated.
- These records contained conflicting values, particularly in `delivered_ts` and `payment_mode`.
- Some duplicate records had missing values while other records contained populated values.

**Solution:** Deduplicate using `order_id` and prioritize records with fewer missing values in `payment_mode` and `delivered_ts`.

#### Issue 3 — Invalid Delivery Timestamps

- 249 orders were identified where `delivered_ts` was earlier than `order_ts`.
- These records indicate invalid delivery timestamp sequences.
- Including them could distort delivery duration and SLA calculations.

**Solution:** Remove orders with invalid delivery timestamps and remove their associated order-item records.

#### Issue 4 — Missing Delivery Timestamps

- 24,234 records contain missing `delivered_ts` values.
- Missing delivery timestamps may represent incomplete delivery information or orders without a recorded delivery time.
- These values should not automatically be treated as zero delivery time.

**Solution:** The duplicate-selection rule prefers records with fewer missing values. However, the script does not remove or otherwise resolve all remaining missing delivery timestamps.

#### Issue 5 — Missing Payment Mode Values

- The `payment_mode` column contains missing values.
- Literal `"NA"` strings are converted into proper null values during text cleaning.
- The duplicate-selection process prefers records with populated payment information when possible.

**Solution:** Normalize missing-value representations and retain the missing values where no valid replacement is available.

#### Issue 6 — Orders Without Valid Item Quantities

- 238 orders were identified whose associated item quantities summed to zero.
- These orders do not contain valid purchased quantities after applying the quantity rule.
- Keeping them in sales analysis could produce misleading order and revenue metrics.

**Solution:** Remove the identified order IDs from the main `orders` table.

### Cleaning Techniques and Python Code

#### A. Identify Invalid Delivery Timestamps

```python
d_order_id = orders[
    orders['delivered_ts'] < orders['order_ts']
]['order_id'].to_list()
```

This identifies orders where the delivery timestamp is earlier than the order timestamp.

#### B. Remove Invalid Orders

```python
orders.drop(
    orders[
        orders['delivered_ts'] < orders['order_ts']
    ].index,
    inplace=True
)
```

The invalid orders are removed from the main orders table.

#### C. Count Missing Values in Important Columns

```python
orders['null_count'] = orders[
    ['payment_mode', 'delivered_ts']
].isnull().sum(axis=1)
```

This creates a temporary column containing the number of missing values across the two selected columns.

#### D. Prioritize More Complete Duplicate Records

```python
orders = orders.sort_values(
    by=['order_id', 'null_count']
)

orders = orders.drop_duplicates(
    subset=['order_id'],
    keep='first'
)

orders = orders.drop(columns=['null_count'])

orders = orders.reset_index(drop=True)
```

The records are sorted by `order_id` and missing-value count.

The record with fewer missing values is retained for each duplicated order ID.

#### E. Remove Orders Without Valid Item Quantities

```python
delete_order_id = (
    order_items
    .groupby('order_id')
    .agg({'qty': 'sum'})
    .query('qty == 0')
    .index
    .tolist()
)
```

The code identifies order IDs whose total item quantity equals zero.

These orders are removed using:

```python
orders.drop(
    orders[
        orders['order_id'].isin(delete_order_id)
    ].index,
    inplace=True
)
```

### Final Orders Table

| Metric | Before Cleaning | After Cleaning |
|---|---:|---:|
| Rows | 400,600 | 399,513 |
| Columns | 9 | 9 |
| Duplicate Order IDs | Present | Removed |
| Invalid Delivery Timestamp Orders | 249 identified | Removed |

**Final Shape:** `(399513, 9)`

---

## 4.2 Order Items

### Table Overview

| Metric | Value |
|---|---:|
| Total Original Rows | 1,163,045 |
| Total Columns | 6 |
| Exact Duplicate Rows | 1,744 |
| Duplicate Percentage | 0.15% |

### Column Profiling

| Column Name | Pandas Data Type | Logical Type | Null Values | Unique Values |
|---|---|---|---:|---:|
| `order_id` | object | Text | 0 | 400,000 |
| `sku_id` | object | Text | 0 | 2,744 |
| `qty` | int64 | Number | 0 | 7 |
| `mrp` | float64 | Number | 0 | 384 |
| `discount_pct` | float64 | Number | 0 | 6 |
| `fulfilled_flag` | int64 | Number | 0 | 2 |

### Issues Identified

#### Issue 1 — Exact Duplicate Records

- 1,744 exact duplicate rows were found.
- Duplicate line items can inflate quantities and sales-related calculations.

**Solution:** Remove all exact duplicate rows using `drop_duplicates()`.

#### Issue 2 — Zero-Quantity Items

- 2,400 rows contain `qty = 0`.
- An order item with zero quantity does not represent a valid purchased quantity for the analysis.

**Solution:** Remove all item records where `qty` equals zero.

#### Issue 3 — Invalid SKU Identifiers

- 499 rows reference 244 SKU identifiers that were reported as invalid against the products master.
- The products table contains 2,500 valid SKU identifiers.
- Invalid SKU references can cause unmatched records during joins with the products table.

**Solution implemented:** Remove item records whose SKU identifier is greater than the configured cutoff `SKU02500`.

```python
order_items.drop(
    order_items[
        order_items['sku_id'] > 'SKU02500'
    ].index,
    inplace=True
)
```

**Important limitation:** This code checks a string cutoff. It does not directly compare each `sku_id` against the actual `products['sku_id']` values. Therefore, it is a range-based filter, not a complete referential-integrity validation.

#### Issue 4 — Items Belonging to Invalid Orders

- 699 order-item rows were associated with orders having invalid delivery timestamps.
- Keeping these item records would create inconsistencies when joining the order and order-item tables.

**Solution:** Remove item rows associated with the invalid order IDs identified from the orders table.

```python
order_items.drop(
    order_items[
        order_items['order_id'].isin(d_order_id)
    ].index,
    inplace=True
)
```

#### Issue 5 — Orders Without Valid Items

- 238 orders were identified with a total item quantity of zero.
- These orders were removed from the orders table.
- Their invalid item rows were also filtered through the zero-quantity removal process.

### Cleaning Techniques and Python Code

#### A. Identify Orders With Zero Total Quantity

```python
delete_order_id = (
    order_items
    .groupby('order_id')
    .agg({'qty': 'sum'})
    .query('qty == 0')
    .index
    .tolist()
)
```

#### B. Remove Zero-Quantity Items

```python
order_items.drop(
    order_items[
        order_items['qty'] == 0
    ].index,
    inplace=True
)
```

#### C. Remove SKU Values Above the Configured Limit

```python
order_items.drop(
    order_items[
        order_items['sku_id'] > 'SKU02500'
    ].index,
    inplace=True
)
```

#### D. Remove Items Associated With Invalid Orders

```python
order_items.drop(
    order_items[
        order_items['order_id'].isin(d_order_id)
    ].index,
    inplace=True
)
```

### Final Order Items Table

| Metric | Before Cleaning | After Cleaning |
|---|---:|---:|
| Rows | 1,163,045 | 1,157,703 |
| Columns | 6 | 6 |
| Exact Duplicate Rows | 1,744 | Removed |
| Zero-Quantity Items | 2,400 identified | Removed |
| Invalid SKU Rows | 499 identified | Filtered by configured SKU cutoff |
| Invalid-Order Item Rows | 699 identified | Removed |

**Final Shape:** `(1157703, 6)`

---

# 5. Common Data Cleaning Functions

The following cleaning operations were implemented as part of the reusable `load_dataset()` function.

## 5.1 Schema Validation

Each dataset is checked to ensure that all expected columns are available before cleaning.

```python
required_columns = tables[
    Path(file_name).stem
]['required_columns']

missing_columns = [
    col for col in required_columns
    if col not in df.columns
]

if missing_columns:
    raise InvalidOrderError(
        f"Missing columns: {missing_columns}"
    )
```

**Purpose:**

- Detect missing required columns.
- Prevent processing tables with an unexpected structure.
- Ensure consistency between the source CSV files and the expected schema.

## 5.2 Text Standardization

```python
for col in text_columns:
    df[col] = df[col].str.strip().str.upper()

    df[col] = df[col].replace(
        ['', 'NA', 'N/A', 'na', 'n/a'],
        np.nan
    )
```

**Techniques used:**

- `.str.strip()` removes leading and trailing whitespace.
- `.str.upper()` standardizes text values to uppercase.
- `.replace()` converts common missing-value strings into `NaN`.

## 5.3 Date and Time Conversion

```python
for col in date_columns:
    df[col] = pd.to_datetime(df[col])
```

**Purpose:**

- Convert date and timestamp columns from object to datetime.
- Support date-based filtering and calculations.
- Enable delivery-duration and time-based analysis.

## 5.4 Numeric Data Type Conversion

```python
for col in numerical_columns:
    df[col] = pd.to_numeric(df[col])
```

**Purpose:**

- Convert numeric columns into suitable numeric data types.
- Support mathematical operations and aggregations.
- Prevent numerical values from being treated as text.

## 5.5 Exact Duplicate Removal

```python
have_duplicates = df.duplicated().sum()

if have_duplicates != 0:
    df.drop_duplicates(inplace=True)
```

**Purpose:**

- Identify completely duplicated records.
- Remove repeated rows.
- Prevent duplicate records from affecting analysis.

## 5.6 Export Cleaned Datasets

```python
df.to_csv(
    DESTINATION_DATA_DIR / file_name,
    index=False
)
```

**Purpose:**

- Export the processed DataFrame as a CSV file.
- Exclude the DataFrame index from the output.
- Keep cleaned files separate from the original source datasets.

---

# 6. Pipeline Logging and Execution Time

The cleaning script also uses logging and decorators to track pipeline execution.

## 6.1 Logging Configuration

```python
logging.basicConfig(
    filename="quickkart_pipeline.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    force=True
)
```

The log file records:

- Function execution started.
- Function execution completed.
- Errors encountered during execution.

## 6.2 Execution Time Decorator

```python
def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()

        try:
            return func(*args, **kwargs)
        finally:
            end = time.perf_counter()

            print(
                f"{func.__name__} executed in "
                f"{end - start:.4f} seconds"
            )

    return wrapper
```

The decorator measures and prints the execution time of the dataset-loading function.

## 6.3 Logging Decorator

```python
def log(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        logging.info(f"Started: {func.__name__}")

        try:
            result = func(*args, **kwargs)
            logging.info(f"Completed: {func.__name__}")
            return result

        except Exception:
            logging.exception(f"Failed: {func.__name__}")
            raise

    return wrapper
```

The decorator records the start, successful completion, or failure of a function.

---

# 7. Final Data Quality Summary

The following table compares the original dataset sizes with the final cleaned dataset sizes.

| Table Name | Original Rows | Cleaned Rows | Rows Removed | Columns |
|---|---:|---:|---:|---:|
| `products` | 2,500 | 2,500 | 0 | 7 |
| `stores` | 40 | 40 | 0 | 5 |
| `riders` | 1,200 | 1,200 | 0 | 5 |
| `daily_stock_snapshot` | 876,800 | 876,800 | 0 | 5 |
| `orders` | 400,600 | 399,513 | 1,087 | 9 |
| `order_items` | 1,163,045 | 1,157,703 | 5,342 | 6 |
| **Total** | **2,444,185** | **2,436,753** | **7,432** | **37** |

### Final Dataset Shapes

```python
daily_stock_snapshot.shape
# (876800, 5)

orders.shape
# (399513, 9)

order_items.shape
# (1157703, 6)

stores.shape
# (40, 5)

products.shape
# (2500, 7)

riders.shape
# (1200, 5)
```

---

# 8. Important Validation Notes & Limitations

The following points should be considered when interpreting the cleaned datasets.

### 8.1 Missing Delivery Timestamps

The script does not remove all orders with missing `delivered_ts` values.

This is intentional in the current implementation, but such orders should be excluded from delivery-duration calculations unless their delivery status and missing-value meaning are properly handled.

### 8.2 SKU Validation

The current implementation uses:

```python
order_items['sku_id'] > 'SKU02500'
```

This assumes a consistent, zero-padded SKU naming convention.

A stronger referential-integrity check would compare item identifiers directly against the products master:

```python
valid_skus = set(products['sku_id'])

invalid_sku_rows = order_items[
    ~order_items['sku_id'].isin(valid_skus)
]
```

This verifies whether an SKU actually exists in the products table.

### 8.3 Orders With No Valid Items

The current script calculates zero-total-quantity orders before removing zero-quantity rows and invalid SKU records.

For stronger validation, recalculate valid item totals after all item-level filters have been applied. Otherwise, an order containing only invalid SKU items could remain in the orders table.

### 8.4 Invalid Timestamp and Duplicate Order Handling

The current script identifies invalid timestamp order IDs before deduplicating orders.

If one duplicate record has an invalid timestamp but another record for the same order is valid, the item-removal step may still remove that order's item records.

A stronger approach would deduplicate orders first and then identify invalid timestamps from the retained records.

### 8.5 Missing Parent Hub IDs

The six missing `parent_hub_id` values in the stores table remain unresolved.

They should be investigated against the source data or business rules before assigning replacement values.

### 8.6 Missing Values Are Not Always Errors

Missing values in fields such as `delivered_ts`, `payment_mode`, `vehicle_type`, and `parent_hub_id` should not automatically be deleted.

Their treatment should depend on the business meaning of each field and the analysis being performed.

---

# 9. Conclusion

The QuickKart data cleaning process identified and addressed several data quality issues across the six source tables.

The major cleaning operations included:

- Schema validation.
- Text standardization.
- Missing-value normalization.
- Date and numeric type conversion.
- Exact duplicate removal.
- Duplicate order resolution.
- Invalid delivery timestamp removal.
- Zero-quantity item removal.
- Invalid SKU range filtering.
- Removal of item records associated with invalid orders.
- Export of cleaned datasets.

After processing, the dataset contains **2,436,753 records across six tables**, compared with the original 2,444,185 records.

The cleaned datasets provide a more consistent foundation for SQL analysis, Excel-based analysis, and Power BI reporting.
