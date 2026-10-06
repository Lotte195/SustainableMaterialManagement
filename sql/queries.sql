-- One of the queries we used was finding the average recycling efficiency rate per country, ranked from highest to lowest. 
-- And if we know which countries are better at recycling on average we can identify what the better strategies are, since there are multiple ones. 
SELECT c.country_name, AVG(rc.recycling_efficiency_rate) AS avg_efficiency -- selects country name and calculates the average recycling efficiency 
FROM country c -- start from the country table and c becomes the alias 
JOIN recycling_company rc ON c.country_id = rc.country_id -- country <-> recycling_company 
GROUP BY c.country_id, c.country_name -- turns these rows in one group 
ORDER BY avg_efficiency DESC;  -- this gives us the order of average efficiency of each country from highest to lowest 


-- The other query that we used was "WHERE NOT EXISTS" to remove suppliers that use an extraction method with the highest environmental risk rating (5).
-- This means that the results only include suppliers that do not have an extraction method with a risk rating of 5, so all lower-risk suppliers remain.
-- Because MySQL does not have a "minus" operation for this purpose, we use "WHERE NOT EXISTS" to exclude the suppliers with the highest risk rating.
-- This is important for our database to recognize companies that don't use the highest risk level, and invest in them, because it has less of a negative effect on the environment.
SELECT s.supplier_id, s.supplier_name, c.country_name  -- picks out supplier id, name and country name 
FROM supplier s -- starts from supplier country and s becomes the  alias 
JOIN country c ON s.country_id = c.country_id -- country <-> supplier
WHERE NOT EXISTS (        -- keeps this supplier only if subquery below finds NOTHING 
    SELECT 1              -- placeholder to check existence 
    FROM extraction e      -- starts from extraction, e becomes the alias 
    JOIN extraction_method em ON e.extraction_method_id = em.extraction_method_id -- extraction <-> extraction_method 
    WHERE e.supplier_id = s.supplier_id         -- match extractions to specific supplier 
    AND em.environmental_risk_rating = 5        -- checks if any of them is rated the highest 
);

-- The last query we used, shows us the waste record with the single highest recovery rate percentage across the whole dataset
-- And this is important, because the highest recovery rate percentage, tells us which country is the best at recovering finite materials. So we can see what methods they use and try to implement them in countries 
-- with for example a very low recovery rate percentage. 
SELECT wr.waste_record_id, pt.product_type_name, c.country_name, r.recover_rate_percent -- picks waste record, product type, country and recovery rate 
FROM waste_record wr -- starts from waste_record and wr becomes the alias 
JOIN product_type pt ON wr.product_type_id = pt.product_type_id -- product_type <-> waste_record
JOIN country c ON wr.country_id = c.country_id -- country <-> waste_record
JOIN recovery r ON wr.waste_record_id = r.waste_record_id -- recovery <-> waste_record
WHERE r.recover_rate_percent >= ALL (SELECT recover_rate_percent FROM recovery); -- keep only the row(s) where the recovery rate is greater than or equal to every other recovery rate in the table    



-- ADD AT LEAST 2 SELECT QUIERIES PER GROUP MEMBER 
-- Clearly indicate who wrote which query (you can use your GitHub names for this) in the documentation.
-- Make sure to document your queries:
-- Add an explanation of which question they answer
-- Add how answering this question is relevant to your societal problem statement

-- Query 4 (by fz-a36)
-- Question: which countries recover the largest total quantity of material through their recycling companies?
-- Relevance: the average efficiency per country only shows how good the recycling companies are, not how much material they actually recover.
-- By looking at the total recovered quantity per country, we see where finite materials are really being brought back into use, and which countries have recycling infrastructure that other countries could learn from.
SELECT c.country_name, SUM(r.quantity_recovered) AS total_recovered -- selects country name and the total quantity recovered in that country
FROM recovery r -- start from recovery and r becomes the alias
JOIN recycling_company rc ON r.recycling_company_id = rc.recycling_company_id -- recovery <-> recycling_company
JOIN country c ON rc.country_id = c.country_id -- recycling_company <-> country
GROUP BY c.country_id, c.country_name -- one row per country
ORDER BY total_recovered DESC; -- countries that recover the most come first

-- Query 5 (by fz-a36)
-- Question: which countries have a recycling efficiency that is higher than the average of all recycling companies, and how many recycling companies do they have?
-- Relevance: the first query ranks all countries, but this one shows only the countries that perform better than the global average.
-- These are the countries whose recycling strategies are worth copying. The company count shows whether a good score
-- comes from one single company or from a whole recycling sector, which tells us how reliable the result is.
SELECT c.country_name, COUNT(rc.recycling_company_id) AS number_of_companies, AVG(rc.recycling_efficiency_rate) AS avg_efficiency -- selects country name, number of recycling companies and their average efficiency
FROM country c -- start from the country table and c becomes the alias
JOIN recycling_company rc ON c.country_id = rc.country_id -- country <-> recycling_company
GROUP BY c.country_id, c.country_name -- one row per country
HAVING AVG(rc.recycling_efficiency_rate) > (SELECT AVG(recycling_efficiency_rate) FROM recycling_company) -- keeps only countries above the overall average (HAVING filters groups, WHERE filters rows)
ORDER BY avg_efficiency DESC; -- best countries first

-- Query 6 (Marthaobi)
-- Question: within each country, which single recycling company is the top performer, and what is its efficiency rate?
-- Relevance: the country-level average (Query 1) can hide the fact that one strong company is dragging up a weak sector's
-- numbers, or that a country's average is already driven by one clear leader. Pinpointing the top company per country
-- lets us study exactly which company's practices are worth documenting and exporting to other countries.
SELECT country_name, recycling_company_name, recycling_efficiency_rate
FROM (
    SELECT c.country_name,
           rc.recycling_company_name,
           rc.recycling_efficiency_rate,
           RANK() OVER (PARTITION BY c.country_id ORDER BY rc.recycling_efficiency_rate DESC) AS rnk -- ranks companies within each country, resets per country
    FROM recycling_company rc -- start from recycling_company
    JOIN country c ON rc.country_id = c.country_id -- recycling_company <-> country
) ranked
WHERE rnk = 1 -- keep only the #1 company per country
ORDER BY recycling_efficiency_rate DESC;


-- Query 7 (Marthaobi)
-- Question: which product types have no waste_record at all?
-- Relevance: our societal problem is about managing material lifecycles responsibly, but we can only manage what we
-- actually monitor. This query exposes product categories that are being manufactured (they may still appear in
-- factory_product) but have a complete monitoring gap in the waste pipeline . Exactly the kind of blind spot that
-- lets illegal dumping or unreported waste slip through unnoticed.
SELECT pt.product_type_id, pt.product_type_name -- picks out the product type with no tracked outcome
FROM product_type pt -- start from product_type
LEFT JOIN waste_record wr ON pt.product_type_id = wr.product_type_id -- product_type <-> waste_record (keep unmatched rows too)
WHERE wr.waste_record_id IS NULL; -- no matching waste_record exists at all
