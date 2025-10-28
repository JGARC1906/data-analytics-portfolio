# 🛒 Amazon Sales Data Analysis  

**Project Date:** October 2025  
**Tools Used:** MySQL · Power BI · Exploratory Analysis · Data Cleaning · Data Visualization · Business Insights  .

## 📘 Overview  

This project focuses on analyzing **Amazon Sales data** to understand which **payment methods** generated the most **revenue** and which experienced the highest **cancellation rates**.  
The main goal was to identify customer payment preferences and evaluate their impact on total revenue across different cities.  

## ⚙️ Methodology  

The project followed a complete analytics workflow from data exploration to insight generation:  

1. **Data Understanding** – Reviewed the dataset and identified key variables such as order_id, category, city, payment_method, status, quantity, and total_sales.  
2. **Data Cleaning (MySQL)** – Checked for missing values and duplicates in order_id but found no major inconsistencies due to a small and clean dataset.  
3. **Data Transformation** – Created **CTEs (Common Table Expressions)** to group information, calculate **percentages**, **rankings**, and summarize revenue and cancellations by payment method.  
4. **Exploratory Analysis** – Queried payment distribution, total orders, and average sales performance by category and city.  
5. **Visualization (Power BI)** – Built interactive visuals to present insights using bar charts, line charts, donuts, tables, and KPI cards.  

project structure 

Amazon-Sales-Data-Analysis/
│
├── SQL/
│   └── [`amazon_sales_copy_2025.sql`](./SQL/amazon_sales_copy_2025.sql)

├── PowerBI/
│   └── [`amazon_sales_copy_dashboard.pbix`](./PowerBI/amazon_sales_copy_dashboard.pbix)

│
 ## 📸 Dashboard Preview  

### 🧭 Main Dashboard  
![Main Dashboard](./Images/Screenshot%202025-10-06%20131920.png)

###  Cancellations  
![Cancellations](./Images/Screenshot%202025-10-06%20131931.png)

### 👥 Top Customers  
![Top Customers](./Images/Screenshot%202025-10-06%20131945.png)

└── README.md

## 💡 Key Insights  

- 💳 **Credit Card** and **PayPal** were the most used payment methods, generating the majority of total orders.  
- 🪙 **Amazon Pay** showed **high efficiency** with fewer cancellations, making it a potentially reliable method.  
- 🎁 **Gift Cards** had one of the **highest cancellation rates**, suggesting potential customer dissatisfaction or error patterns.  
- 🏙️ Among cities, the top-performing ones (e.g., Los Angeles and Dallas) had higher order averages and consistent revenue patterns.  
- 📉 Overall, cancellation-related revenue loss was moderate but concentrated in a few categories, signaling optimization opportunities.  


## 🚀 Conclusion  

This project demonstrates my ability to turn raw transactional data into actionable business insights through SQL analysis and Power BI visualization.  
It highlights my analytical thinking, data storytelling, and attention to business impact — key qualities for a **Data Analyst** role.  


## 🆕 Project 2: Retail Sales Data Analysis (MySQL + Power BI)

**Project Date:** October 2025  
**Tools Used:** MySQL · Power BI · Exploratory Analysis · Data Cleaning · Data Visualization · Business Insights  .

🧾 Overview

This project explores a retail sales dataset to identify trends in revenue generation, customer demographics, and product category performance. Using SQL for data cleaning and analysis, and Power BI for visualization, the goal was to transform raw transactional data into actionable business insights.

⚙️ Methodology

Data Cleaning & Preparation (SQL)
   Verified and removed incomplete or duplicate transactions.
   Filtered dataset to focus on sales for 2023.
   Created aggregated tables using CTEs and GROUP BY for key metrics such as total      revenue, quantity sold, and average order value.

Data Analysis (SQL)
    Grouped customers by age range and analyzed total revenue and average order          values.
    Compared product categories (Electronics, Clothing, Beauty) by transactions,         quantity sold, and total revenue.

Data Visualization (Power BI)
     Designed dashboards focused on Revenue by Age Group and Revenue by Category.
     Added KPI cards to summarize metrics like total revenue, units sold, and             average order value.

│
├── SQL/
│   └── [`retail_sales_data.sql`](./SQL/retail_sales_data.sql)

├── PowerBI/
│   └── [`proyect_retail_sales_data.pbix`](./PowerBI/proyect_retail_sales_data.pbix)


 ## 📸 Dashboard Preview  

## 👥 Age Group
![Revenue by age group](./Images/Screenshot%202025-10-28%20142145.png)

##  Category
![Revenue by category](./Images/Screenshot%202025-10-28%20142158.png)

💡 Key Insights

- Mature Adults (41–60) generated the highest revenue ($192K), while Seniors (61+)     contributed the least ($33K).
- Young Adults (18–25) and Adults (26–40) showed higher average order values,          suggesting strong potential for targeted marketing.
- Electronics led in both revenue ($157K) and units sold, indicating consistent        demand.
- Clothing followed closely with balanced performance and efficient pricing per unit.
- Beauty underperformed due to lower transaction volume, presenting an opportunity     for promotional campaigns.

🧠 Conclusion
- Focus marketing efforts on younger segments to convert higher spending potential into increased frequency.
- Maintain the strong performance of electronics while optimizing beauty through seasonal or targeted promotions.


## 📬 Contact  

- 📧 Email: [jarcia123@outlook.com](mailto:jarcia123@outlook.com)  
- 💼 LinkedIn: [Javier Garcia](https://www.linkedin.com/in/javier-garcia-70817024b)

