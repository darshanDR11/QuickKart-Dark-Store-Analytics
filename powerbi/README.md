# QuickKart Dark-Store Delivery & Stock-Out Analytics — Power BI Dashboard Analysis

## Tools Used

- **Power BI Desktop** – Data modelling, DAX calculations, interactive visualizations, and dashboard development.
- **Python** – Data cleaning and data loading using the Python script feature in Power BI.
- **Dataset** – QuickKart dark-store operations data covering orders, deliveries, revenue, customers, and product categories across multiple Indian cities.

## Dashboards

### 1. Executive Overview Dashboard

![Dashboard 1 - Executive Overview](images/dashboard/01-Executive-Overview.png)

#### Insights

- **Overall business performance:** The dataset records approximately **400K orders**, generating **₹194.95M (₹19.5 Crore)** in revenue.
- **Delivery performance:** On-time delivery stands at **83.45%**, while **16.55%** of orders are delivered late.
- **Revenue leakage:** The business experiences total revenue leakage of **₹26.12M**, representing a significant financial impact from operational issues.
- **Recent delivery decline:** On-time delivery improved to approximately **87–88%** between October 2025 and April 2026 but dropped sharply to around **76%** from May–June 2026.
- **Monthly revenue growth:** Revenue increased from approximately **₹9M in April 2025** to around **₹11.5M–₹12M by mid-2026**, with a peak of nearly **₹13M in October 2025**.
- **City-level delivery performance:** Ahmedabad has the highest late delivery rate at **22.84%**, considerably above the other five cities, which range from **14.70% to 15.67%**.
- **Category-level revenue losses:** Fruits & Vegetables and Beverages each contribute approximately **₹3.7M** in lost revenue, followed by Dairy & Bakery at **₹3.2M**. Together, these categories account for approximately **₹10.6M**, or over **40% of total revenue leakage**.

---

### 2. Delivery Performance Dashboard

![Dashboard 2 - Delivery Performance](images/dashboard/02-Delivery-Performance.png)

#### Insights

- **Order fulfilment:** Approximately **400K orders** were recorded, of which **375K were successfully delivered**. Around **25K orders** remained undelivered or were cancelled.
- **Average delivery time:** The average delivery time across all orders is **12.28 minutes**.
- **Recent delivery decline:** On-time delivery fell from approximately **87%** during the recovery period through April 2026 to around **76–77% by July 2026**.
- **Rush-hour bottlenecks:** Delivery performance consistently deteriorates between **8:00–9:00 AM** and **6:00–9:00 PM (18:00–21:00)** across all days of the week.
- **Store-specific delays:** Store **DS003** dominates the five worst store-hour combinations. Its on-time delivery rate falls to **65.14% at 9:00 AM** and **65.45% at 7:00 PM**.
- **Shift efficiency:** Evening shifts achieve the highest on-time delivery rate at **83.75%**, followed by Morning at **83.48%** and Night at **82.49%**.
- **Top rider performance:** Rider **R00899** leads with **297 delivered orders**, followed by **R00395** with **295**. The top five riders maintain near-100% on-time completion rates.

---

### 3. Revenue Leakage Dashboard

![Dashboard 3 - Revenue Leakage](images/dashboard/03-Revenue-Leakage.png)

#### Insights

- **Total financial leakage:** Revenue leakage amounts to **₹26.12M**, representing **11.81% of total potential revenue**.
- **Leakage by root cause:** Stock-outs account for **₹12.86M**, cancelled orders for **₹9.95M**, and returned orders for **₹3.31M**.
- **Major operational causes:** Stock-outs contribute approximately **49.2%** of total leakage, while cancellations contribute approximately **38.1%**. Together, they account for over **87%** of total revenue leakage.
- **High-loss product categories:** Fruits & Vegetables and Beverages are the largest sources of category-level leakage at approximately **₹3.7M each**, followed by Dairy & Bakery at **₹3.2M**.
- **Seasonal leakage spike:** Monthly revenue leakage reached approximately **₹2.5M in October 2025**, compared with a baseline of around **₹1M during mid-2025**.
- **Increasing leakage baseline:** From March to August 2026, monthly leakage remained around **₹1.5M–₹1.8M**, higher than the approximately ₹1M baseline observed in 2025.
- **City-level cancellation losses:** Within the Cancelled branch of the decomposition tree, Mumbai records approximately **₹22.54L** in losses, followed by Ahmedabad at **₹20.71L**, Pune at **₹18.98L**, and Bengaluru at **₹13.36L**.
- **Ahmedabad South Zone concentration:** Approximately **₹9.17L** of Ahmedabad's **₹20.71L** cancellation losses originate in the South Zone.
- **Store-level cancellation losses:** Within Ahmedabad's South Zone, DS006 contributes approximately **₹3.30L**, DS004 contributes **₹3.12L**, and DS001 contributes **₹2.74L** in cancellation losses.

---

### 4. Customer Analysis Dashboard

![Dashboard 4 - Customer Analysis](images/dashboard/04-Customer-Analysis.png)

#### Insights

- **Customer base:** The dataset contains approximately **45K unique customers**, of whom **24K** are repeat customers.
- **Customer retention:** The overall repeat customer rate is **54.24%**, indicating that more than half of the recorded customer base has made multiple purchases.
- **Purchase frequency:** Customers place an average of **9 orders per customer**.
- **Customer revenue:** The customer base generates approximately **₹194.95M (₹19.5 Crore)** in total revenue.
- **Customer growth:** Total customers increased from approximately **9.0K in April 2025** to around **10.7K–10.9K by August/September 2026**. Repeat customers increased from **3.6K** to approximately **4.5K–4.6K** over the same period.
- **October 2025 seasonal peak:** Total customers reached **11.5K**, while repeat customers reached **5.0K**, representing a noticeable increase compared with surrounding months.
- **City-level repeat customer rates:** Mumbai leads at **49.59%**, followed by Pune at **48.13%** and Ahmedabad at **48.06%**. The six cities fall within a relatively narrow range of **46.15%–49.59%**.
- **Top customer revenue contribution:** Customer **C000051** leads with approximately **₹96K**, followed by **C000215** with **₹94K**.
- **Low revenue concentration:** The top five customers generate approximately **₹465K combined**, representing less than **0.25%** of the total ₹194.95M revenue. This indicates that revenue is distributed across a broad customer base.

---