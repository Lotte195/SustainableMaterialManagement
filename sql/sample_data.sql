USE SustainableMaterialManagement;

-- 1. INSERT SAMPLE DATA

INSERT INTO country (country_id, country_name) VALUES
(1, 'Netherlands'),
(2, 'Germany'),
(3, 'Belgium'),
(4, 'Sweden'),
(5, 'France');

INSERT INTO factory (factory_id, factory_name, country_id) VALUES
(1, 'Eindhoven Electronics Plant', 1),
(2, 'Munich Battery Works', 2),
(3, 'Antwerp Appliance Factory', 3),
(4, 'Malmo Furniture Works', 4),
(5, 'Lyon Electronic Basics', 5);


INSERT INTO supplier (supplier_id, country_id, supplier_name) VALUES
(1, 1, 'Dutch Metals Supply'),
(2, 2, 'Bavaria Raw Materials'),
(3, 3, 'Belgian Glass Partners'),
(4, 4, 'Nordic Gold Mine'),
(5, 5, 'French Silicon Solutions');

INSERT INTO material (material_id, material_name, material_type) VALUES
(1, 'Aluminium', 'Metal'),
(2, 'Copper', 'Metal'),
(3, 'Gold', 'Metal'),
(4, 'Glass', 'Glass'),
(5, 'Silicon', 'Semiconductor');

INSERT INTO recycling_company
(recycling_company_id, country_id, recycling_company_name, recycling_efficiency_rate)
VALUES
(1, 1, 'GreenCycle Netherlands', 88),
(2, 2, 'EcoReclaim Germany', 91),
(3, 3, 'Circular Belgium', 84),
(4, 4, 'Nordic Recycle', 94),
(5, 5, 'Recyclage France', 82);

INSERT INTO product_type
(product_type_id, product_type_name, avg_lifespan_years)
VALUES
(1, 'Smartphone', 4),
(2, 'Laptop', 6),
(3, 'Washing Machine', 11),
(4, 'CPU', 4),
(5, 'Microchip', 8);

INSERT INTO waste_collection_rule
(rule_id, country_id, rule_description)
VALUES
(1, 1, 'Separate electronics collection'),
(2, 2, 'Certified e-waste collection'),
(3, 3, 'Municipal recycling required'),
(4, 4, 'Producer take-back system'),
(5, 5, 'Household recycling points');

INSERT INTO product_fate
(fate_id, fate_type, rule_id)
VALUES
(1, 'Recycled', 1),
(2, 'Refurbished', 2),
(3, 'Landfilled', 3),
(4, 'Incinerated', 4),
(5, 'Export', 5);

INSERT INTO waste_record
(waste_record_id, product_type_id, country_id, fate_id,
 percent_collected, percent_illegal, quantity_collected)
VALUES
(1, 1, 1, 1, 82, 5, 8200),
(2, 2, 2, 2, 88, 3, 4400),
(3, 3, 3, 3, 76, 8, 7600),
(4, 4, 4, 4, 93, 2, 9300),
(5, 5, 5, 5, 71, 10, 3550);

INSERT INTO recovery
(recovery_id, waste_record_id, recycling_company_id,
 quantity_recovered, recover_rate_percent)
VALUES
(1, 1, 1, 7050, 86),
(2, 2, 2, 3960, 90),
(3, 3, 3, 5700, 75),
(4, 4, 4, 8835, 95),
(5, 5, 5, 2840, 80);

INSERT INTO factory_product
(factory_product_id, factory_id, product_type_id)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5);

INSERT INTO extraction_method
(extraction_method_id, method_name, environmental_risk_rating)
VALUES
(1, 'Open Pit Mining', 5),
(2, 'Underground Mining', 4),
(3, 'Glass Recovery', 2),
(4, 'Salvaged Gold', 1),
(5, 'Silicon Wafer Processing', 2);

INSERT INTO extraction
(extraction_id, supplier_id, material_id, extraction_method_id,
 extraction_quantity)
VALUES
(1, 1, 1, 1, 1200),
(2, 2, 2, 2, 850),
(3, 3, 3, 3, 950),
(4, 4, 4, 4, 1100),
(5, 5, 5, 5, 780);

INSERT INTO product_material
(product_type_id, material_id, quantity_per_unit)
VALUES
-- Smartphone
(1, 1, 120),
(1, 2, 25),

-- Laptop
(2, 1, 850),
(2, 2, 180),

-- Washing Machine
(3, 1, 4200),

-- CPU
(4, 4, 90),
(4, 1, 120),
(4, 2, 25),

-- Microchip
(5, 5, 20),
(5, 2, 5),
(5, 1, 2);

INSERT INTO waste_collection_company
(company_id, country_id, waste_collection_company_name, collection_fee)
VALUES
(1, 1, 'Amsterdam Waste Services', 25),
(2, 2, 'Berlin Circular Collection', 30),
(3, 3, 'Brussels Eco Collection', 22),
(4, 4, 'Stockholm Waste Solutions', 28),
(5, 5, 'Paris Recycling Services', 24);

-- 2. CHECK THAT DATA WAS INSERTED

SELECT 'country' AS table_name, COUNT(*) AS row_count
FROM country

UNION ALL

SELECT 'factory', COUNT(*)
FROM factory

UNION ALL

SELECT 'supplier', COUNT(*)
FROM supplier

UNION ALL

SELECT 'material', COUNT(*)
FROM material

UNION ALL

SELECT 'recycling_company', COUNT(*)
FROM recycling_company

UNION ALL

SELECT 'product_type', COUNT(*)
FROM product_type

UNION ALL

SELECT 'waste_collection_rule', COUNT(*)
FROM waste_collection_rule

UNION ALL

SELECT 'product_fate', COUNT(*)
FROM product_fate

UNION ALL

SELECT 'waste_record', COUNT(*)
FROM waste_record

UNION ALL

SELECT 'recovery', COUNT(*)
FROM recovery

UNION ALL

SELECT 'factory_product', COUNT(*)
FROM factory_product

UNION ALL

SELECT 'extraction_method', COUNT(*)
FROM extraction_method

UNION ALL

SELECT 'extraction', COUNT(*)
FROM extraction

UNION ALL

SELECT 'product_material', COUNT(*)
FROM product_material

UNION ALL

SELECT 'waste_collection_company', COUNT(*)
FROM waste_collection_company;
