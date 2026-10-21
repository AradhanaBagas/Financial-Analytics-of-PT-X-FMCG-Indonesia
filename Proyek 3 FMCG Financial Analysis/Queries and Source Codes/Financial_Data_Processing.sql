CREATE DATABASE fmcg_financial_analysis;

USE fmcg_financial_analysis;

SELECT * FROM dim_product_fixed;
SELECT * FROM fact_sales_monthly_fixed;
SELECT * FROM fact_working_capital_monthly_fixed;

SELECT 
Month_1 AS Months,
SKU_Code_2 AS SKU_Code, 
SKU_Name, 
Channels, 
Base_List_Price_2 AS Base_List_Price,
ROUND(Base_List_Price_2 * (1 - (Trade_Discount + Rebates_Listing_Fee)/Gross_Revenue)) AS Net_Price_per_Unit,
Gross_Revenue, 
Net_Revenue, 
Net_Revenue/Gross_Revenue AS GtN_Revenue, 
1-Net_Revenue/Gross_Revenue AS GtN_Leakage, 
Units_Sold,
ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
) AS Baseline_Units_Sold,
Units_Sold - ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
) AS Volume_Lift,
Trade_Discount + Rebates_Listing_Fee + Marketing_AP AS Promotion_Cost,
(Units_Sold - ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
)) * (Base_List_Price_2 - ROUND(Total_COGS/Units_Sold)) AS Incremental_Gross_Profit,
(Units_Sold - ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
)) * (Base_List_Price_2 - ROUND(Total_COGS/Units_Sold)) / (Trade_Discount + Marketing_AP) AS Promotion_ROI,
Total_COGS,
Gross_Profit,
Gross_Profit/Net_Revenue AS Gross_Margin,
Marketing_AP,
Marketing_AP/Net_Revenue AS AnP_per_Net_Revenue
FROM fact_sales_monthly_fixed
LEFT JOIN dim_product_fixed ON SKU_Code_1 = SKU_Code_2
ORDER BY Months, SKU_Code, Channels;

CREATE VIEW working_capital AS
SELECT * FROM fact_working_capital_monthly_fixed;

CREATE VIEW sales AS
SELECT 
Month_1 AS Months,
SKU_Code_2 AS SKU_Code, 
SKU_Name, 
Channels, 
Base_List_Price_2 AS Base_List_Price,
ROUND(Base_List_Price_2 * (1 - (Trade_Discount + Rebates_Listing_Fee)/Gross_Revenue)) AS Net_Price_per_Unit,
Gross_Revenue, 
Net_Revenue, 
Net_Revenue/Gross_Revenue AS GtN_Revenue, 
1-Net_Revenue/Gross_Revenue AS GtN_Leakage, 
Units_Sold,
ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
) AS Baseline_Units_Sold,
Units_Sold - ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
) AS Volume_Lift,
Trade_Discount + Rebates_Listing_Fee + Marketing_AP AS Promotion_Cost,
(Units_Sold - ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
)) * (Base_List_Price_2 - ROUND(Total_COGS/Units_Sold)) AS Incremental_Gross_Profit,
(Units_Sold - ROUND(
	AVG(
		CASE 
			WHEN SUBSTR(Month_1, 6, 2) NOT IN ('03', '04', '12') THEN Units_Sold 
		END
	) OVER (PARTITION BY SKU_Code_2, Channels)
)) * (Base_List_Price_2 - ROUND(Total_COGS/Units_Sold)) / (Trade_Discount + Marketing_AP) AS Promotion_ROI,
Total_COGS,
Gross_Profit,
Gross_Profit/Net_Revenue AS Gross_Margin,
Marketing_AP,
Marketing_AP/Net_Revenue AS AnP_per_Net_Revenue
FROM fact_sales_monthly_fixed
LEFT JOIN dim_product_fixed ON SKU_Code_1 = SKU_Code_2
ORDER BY Months, SKU_Code, Channels;