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
WHERE r.recover_rate_percent >= ALL (SELECT recover_rate_percent FROM recovery); -- keep only the row(s) where the recovery rate is greater than or equal to every other recovery rate in the table               -- 
