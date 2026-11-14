# QuickKart — Data Dictionary

This document describes the structure of the six datasets used in the QuickKart Dark-Store Delivery & Analytics project.

**Total Tables:** 6  
**Total Records:** 2,444,185

---

## 1. daily_stock_snapshot

**Total Rows:** 876,800

| Column Name | Data Type | Example Value |
|---|---|---|
| `snapshot_date` | Date/Time | `2025-04-01` |
| `store_id` | Text | `DS001` |
| `sku_id` | Text | `SKU01612` |
| `closing_qty` | Number | `87` |
| `received_qty` | Number | `0` |

---

## 2. order_items

**Total Rows:** 1,163,045

| Column Name | Data Type | Example Value |
|---|---|---|
| `order_id` | Text | `QK0000001` |
| `sku_id` | Text | `SKU00707` |
| `qty` | Number | `1` |
| `mrp` | Number | `461.0` |
| `discount_pct` | Number | `0.25` |
| `fulfilled_flag` | Number | `1` |

---

## 3. orders

**Total Rows:** 400,600

| Column Name | Data Type | Example Value |
|---|---|---|
| `order_id` | Text | `QK0000001` |
| `customer_id` | Text | `C003022` |
| `store_id` | Text | `DS024` |
| `order_ts` | Date/Time | `2025-04-01 00:18:16` |
| `rider_id` | Text | `R00144` |
| `delivered_ts` | Date/Time | `2025-04-01 00:28:16` |
| `promised_mins` | Number | `15` |
| `status` | Text | `Delivered` |
| `payment_mode` | Text | `Cash on Delivery` |

---

## 4. products

**Total Rows:** 2,500

| Column Name | Data Type | Example Value |
|---|---|---|
| `sku_id` | Text | `SKU00001` |
| `sku_name` | Text | `Tata Namkeen Regular 500g` |
| `category` | Text | `Snacks` |
| `sub_category` | Text | `Namkeen` |
| `brand` | Text | `Tata` |
| `mrp` | Number | `277.0` |
| `shelf_life_days` | Number | `120` |

---

## 5. riders

**Total Rows:** 1,200

| Column Name | Data Type | Example Value |
|---|---|---|
| `rider_id` | Text | `R00001` |
| `store_id` | Text | `DS001` |
| `join_date` | Date/Time | `2025-12-15` |
| `shift` | Text | `Morning` |
| `vehicle_type` | Text | `EV Scooter` |

---

## 6. stores

**Total Rows:** 40

| Column Name | Data Type | Example Value |
|---|---|---|
| `store_id` | Text | `DS001` |
| `city` | Text | `Ahmedabad` |
| `zone` | Text | `South` |
| `opening_date` | Date/Time | `2025-01-24` |
| `parent_hub_id` | Text | `DS001` |

---

## Dataset Summary

| Table Name | Total Rows | Total Columns |
|---|---:|---:|
| `daily_stock_snapshot` | 876,800 | 5 |
| `order_items` | 1,163,045 | 6 |
| `orders` | 400,600 | 9 |
| `products` | 2,500 | 7 |
| `riders` | 1,200 | 5 |
| `stores` | 40 | 5 |
| **Total** | **2,444,185** | **37** |

---

**Note:** Data types and example values are based on the supplied dataset metadata. Example values illustrate the expected format and are not intended to represent every possible value in a column.
