-- SELECT * FROM df_orders;

-- ==============================
-- 📊 Top 10 Receita por Produto
-- ==============================

SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- =============================
-- 🌍 Top 5 Receitas por Região
-- =============================

WITH region_sales AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
    )
SELECT *
FROM (
    SELECT region, product_id, sales,
           ROW_NUMBER() OVER(
               PARTITION BY region
               ORDER BY sales DESC
           ) AS rn
    FROM region_sales) sub
WHERE rn<=5;

-- =======================================
-- 📈 Crescimento Anual Através dos Meses
-- =======================================

WITH sales_month AS (
    SELECT strftime('%Y', order_date) AS ano,
        strftime('%m', order_date) AS mes,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY ano, mes
    )
SELECT mes,
       ROUND(SUM(CASE WHEN ano = '2022' THEN sales ELSE 0 END), 2) AS sales_2022,
       ROUND(SUM(CASE WHEN ano = '2023' THEN sales ELSE 0 END), 2) AS sales_2023
FROM sales_month
GROUP BY mes
ORDER BY mes;

-- =============================================
-- 🛒 Maiores Vendas Mensais Para Cada Categoria
-- =============================================

WITH sales_category AS (
    SELECT category, 
           strftime('%m-%Y', order_date) AS month_year,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, month_year
)
SELECT *
FROM (
    SELECT category, month_year, sales,
           ROW_NUMBER() OVER(
               PARTITION BY category
               ORDER BY sales DESC
           ) AS rn
    FROM sales_category) sub
WHERE rn=1;

-- =============================================================
-- 💰 Crescimento Percentual das Vendas Anuais por Subcategorias
-- =============================================================

WITH sales_sub_category AS (
    SELECT 
        sub_category,
        strftime('%Y', order_date) AS ano,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, ano
    ),
growth AS (
    SELECT sub_category,
        ROUND(SUM(CASE WHEN ano = '2022' THEN sales ELSE 0 END), 2) AS sales_2022,
        ROUND(SUM(CASE WHEN ano = '2023' THEN sales ELSE 0 END), 2) AS sales_2023
    FROM sales_sub_category
    GROUP BY sub_category
    )
SELECT *,
       ROUND(((sales_2023 - sales_2022) * 100 / sales_2022), 2) AS growth_percent
FROM growth
ORDER BY growth_percent DESC;