USE SustainableMaterialManagement;

-- 1. Add Constraints

ALTER TABLE country
    MODIFY country_id INT NOT NULL,
    MODIFY country_name VARCHAR(56) NOT NULL,
    ADD CONSTRAINT chk_country_id
        CHECK (country_id > 0),
    ADD CONSTRAINT chk_country_name
        CHECK (CHAR_LENGTH(TRIM(country_name)) > 0),
    ADD CONSTRAINT uq_country_name
        UNIQUE (country_name);

ALTER TABLE factory
    DROP FOREIGN KEY factory_ibfk_1;

ALTER TABLE factory
    MODIFY factory_id INT NOT NULL,
    MODIFY factory_name VARCHAR(150) NOT NULL,
    MODIFY country_id INT NOT NULL,
    ADD CONSTRAINT chk_factory_id
        CHECK (factory_id > 0),
    ADD CONSTRAINT chk_factory_name
        CHECK (CHAR_LENGTH(TRIM(factory_name)) > 0),
    ADD CONSTRAINT uq_factory_name
        UNIQUE (factory_name),
    ADD CONSTRAINT fk_factory_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id);

ALTER TABLE supplier
    DROP FOREIGN KEY supplier_ibfk_1;

ALTER TABLE supplier
    MODIFY supplier_id INT NOT NULL,
    MODIFY country_id INT NOT NULL,
    MODIFY supplier_name VARCHAR(150) NOT NULL,
    ADD CONSTRAINT chk_supplier_id
        CHECK (supplier_id > 0),
    ADD CONSTRAINT chk_supplier_name
        CHECK (CHAR_LENGTH(TRIM(supplier_name)) > 0),
    ADD CONSTRAINT uq_supplier_name
        UNIQUE (supplier_name),
    ADD CONSTRAINT fk_supplier_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id);

ALTER TABLE material
    MODIFY material_id INT NOT NULL,
    MODIFY material_name VARCHAR(50) NOT NULL,
    MODIFY material_type VARCHAR(50) NOT NULL,
    ADD CONSTRAINT chk_material_id
        CHECK (material_id > 0),
    ADD CONSTRAINT chk_material_name
        CHECK (CHAR_LENGTH(TRIM(material_name)) > 0),
    ADD CONSTRAINT chk_material_type
        CHECK (CHAR_LENGTH(TRIM(material_type)) > 0),
    ADD CONSTRAINT uq_material_name
        UNIQUE (material_name);

ALTER TABLE recycling_company
    DROP FOREIGN KEY recycling_company_ibfk_1;

ALTER TABLE recycling_company
    MODIFY recycling_company_id INT NOT NULL,
    MODIFY country_id INT NOT NULL,
    MODIFY recycling_company_name VARCHAR(150) NOT NULL,
    MODIFY recycling_efficiency_rate INT NOT NULL,
    ADD CONSTRAINT chk_recycling_company_id
        CHECK (recycling_company_id > 0),
    ADD CONSTRAINT chk_recycling_company_name
        CHECK (CHAR_LENGTH(TRIM(recycling_company_name)) > 0),
    ADD CONSTRAINT chk_recycling_efficiency
        CHECK (recycling_efficiency_rate BETWEEN 0 AND 100),
    ADD CONSTRAINT uq_recycling_company_name
        UNIQUE (recycling_company_name),
    ADD CONSTRAINT fk_recycling_company_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id);

ALTER TABLE product_type
    MODIFY product_type_id INT NOT NULL,
    MODIFY product_type_name VARCHAR(50) NOT NULL,
    MODIFY avg_lifespan_years INT NOT NULL,
    ADD CONSTRAINT chk_product_type_id
        CHECK (product_type_id > 0),
    ADD CONSTRAINT chk_product_type_name
        CHECK (CHAR_LENGTH(TRIM(product_type_name)) > 0),
    ADD CONSTRAINT chk_product_lifespan
        CHECK (avg_lifespan_years > 0),
    ADD CONSTRAINT uq_product_type_name
        UNIQUE (product_type_name);

ALTER TABLE waste_collection_rule
    DROP FOREIGN KEY waste_collection_rule_ibfk_1;

ALTER TABLE waste_collection_rule
    MODIFY rule_id INT NOT NULL,
    MODIFY country_id INT NOT NULL,
    MODIFY rule_description VARCHAR(255) NOT NULL,
    ADD CONSTRAINT chk_rule_id
        CHECK (rule_id > 0),
    ADD CONSTRAINT chk_rule_description
        CHECK (CHAR_LENGTH(TRIM(rule_description)) > 0),
    ADD CONSTRAINT fk_rule_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id);

ALTER TABLE product_fate
    DROP FOREIGN KEY product_fate_ibfk_1;

ALTER TABLE product_fate
    MODIFY fate_id INT NOT NULL,
    MODIFY fate_type VARCHAR(50) NOT NULL,
    MODIFY rule_id INT NOT NULL,
    ADD CONSTRAINT chk_fate_id
        CHECK (fate_id > 0),
    ADD CONSTRAINT chk_fate_type
        CHECK (CHAR_LENGTH(TRIM(fate_type)) > 0),
    ADD CONSTRAINT uq_fate_type
        UNIQUE (fate_type),
    ADD CONSTRAINT fk_fate_rule
        FOREIGN KEY (rule_id)
        REFERENCES waste_collection_rule(rule_id);

ALTER TABLE waste_record
    DROP FOREIGN KEY waste_record_ibfk_1,
    DROP FOREIGN KEY waste_record_ibfk_2,
    DROP FOREIGN KEY waste_record_ibfk_3;

ALTER TABLE waste_record
    MODIFY waste_record_id INT NOT NULL,
    MODIFY product_type_id INT NOT NULL,
    MODIFY country_id INT NOT NULL,
    MODIFY fate_id INT NOT NULL,
    MODIFY percent_collected INT NOT NULL,
    MODIFY percent_illegal INT NOT NULL,
    MODIFY quantity_collected INT NOT NULL,
    ADD CONSTRAINT chk_waste_record_id
        CHECK (waste_record_id > 0),
    ADD CONSTRAINT chk_percent_collected
        CHECK (percent_collected BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_percent_illegal
        CHECK (percent_illegal BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_percent_total
        CHECK (percent_collected + percent_illegal <= 100),
    ADD CONSTRAINT chk_quantity_collected
        CHECK (quantity_collected >= 0),
    ADD CONSTRAINT fk_waste_product
        FOREIGN KEY (product_type_id)
        REFERENCES product_type(product_type_id),
    ADD CONSTRAINT fk_waste_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id),
    ADD CONSTRAINT fk_waste_fate
        FOREIGN KEY (fate_id)
        REFERENCES product_fate(fate_id);

ALTER TABLE recovery
    DROP FOREIGN KEY recovery_ibfk_1,
    DROP FOREIGN KEY recovery_ibfk_2;

ALTER TABLE recovery
    MODIFY recovery_id INT NOT NULL,
    MODIFY waste_record_id INT NOT NULL,
    MODIFY recycling_company_id INT NOT NULL,
    MODIFY quantity_recovered INT NOT NULL,
    MODIFY recover_rate_percent INT NOT NULL,
    ADD CONSTRAINT chk_recovery_id
        CHECK (recovery_id > 0),
    ADD CONSTRAINT chk_quantity_recovered
        CHECK (quantity_recovered >= 0),
    ADD CONSTRAINT chk_recovery_rate
        CHECK (recover_rate_percent BETWEEN 0 AND 100),
    ADD CONSTRAINT fk_recovery_waste
        FOREIGN KEY (waste_record_id)
        REFERENCES waste_record(waste_record_id),
    ADD CONSTRAINT fk_recovery_company
        FOREIGN KEY (recycling_company_id)
        REFERENCES recycling_company(recycling_company_id);

ALTER TABLE factory_product
    DROP FOREIGN KEY factory_product_ibfk_1,
    DROP FOREIGN KEY factory_product_ibfk_2;

ALTER TABLE factory_product
    MODIFY factory_product_id INT NOT NULL,
    MODIFY factory_id INT NOT NULL,
    MODIFY product_type_id INT NOT NULL,
    ADD CONSTRAINT chk_factory_product_id
        CHECK (factory_product_id > 0),
    ADD CONSTRAINT uq_factory_product
        UNIQUE (factory_id, product_type_id),
    ADD CONSTRAINT fk_factory_product_factory
        FOREIGN KEY (factory_id)
        REFERENCES factory(factory_id),
    ADD CONSTRAINT fk_factory_product_product
        FOREIGN KEY (product_type_id)
        REFERENCES product_type(product_type_id);

ALTER TABLE extraction_method
    MODIFY extraction_method_id INT NOT NULL,
    MODIFY method_name VARCHAR(50) NOT NULL,
    MODIFY environmental_risk_rating INT NOT NULL,
    ADD CONSTRAINT chk_extraction_method_id
        CHECK (extraction_method_id > 0),
    ADD CONSTRAINT chk_method_name
        CHECK (CHAR_LENGTH(TRIM(method_name)) > 0),
    ADD CONSTRAINT chk_environmental_risk
        CHECK (environmental_risk_rating BETWEEN 1 AND 5),
    ADD CONSTRAINT uq_method_name
        UNIQUE (method_name);

ALTER TABLE extraction
    DROP FOREIGN KEY extraction_ibfk_1,
    DROP FOREIGN KEY extraction_ibfk_2,
    DROP FOREIGN KEY extraction_ibfk_3;

ALTER TABLE extraction
    MODIFY extraction_id INT NOT NULL,
    MODIFY supplier_id INT NOT NULL,
    MODIFY material_id INT NOT NULL,
    MODIFY extraction_method_id INT NOT NULL,
    MODIFY extraction_quantity INT NOT NULL,
    ADD CONSTRAINT chk_extraction_id
        CHECK (extraction_id > 0),
    ADD CONSTRAINT chk_extraction_quantity
        CHECK (extraction_quantity > 0),
    ADD CONSTRAINT fk_extraction_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(supplier_id),
    ADD CONSTRAINT fk_extraction_material
        FOREIGN KEY (material_id)
        REFERENCES material(material_id),
    ADD CONSTRAINT fk_extraction_method
        FOREIGN KEY (extraction_method_id)
        REFERENCES extraction_method(extraction_method_id);

ALTER TABLE product_material
    DROP FOREIGN KEY product_material_ibfk_1,
    DROP FOREIGN KEY product_material_ibfk_2;

ALTER TABLE product_material
    MODIFY product_type_id INT NOT NULL,
    MODIFY material_id INT NOT NULL,
    MODIFY quantity_per_unit DECIMAL(10,3) NOT NULL,
    ADD CONSTRAINT chk_quantity_per_unit
        CHECK (quantity_per_unit > 0),
    ADD CONSTRAINT fk_product_material_product
        FOREIGN KEY (product_type_id)
        REFERENCES product_type(product_type_id),
    ADD CONSTRAINT fk_product_material_material
        FOREIGN KEY (material_id)
        REFERENCES material(material_id);

ALTER TABLE waste_collection_company
    DROP FOREIGN KEY waste_collection_company_ibfk_1;

ALTER TABLE waste_collection_company
    MODIFY company_id INT NOT NULL,
    MODIFY country_id INT NOT NULL,
    MODIFY waste_collection_company_name VARCHAR(150) NOT NULL,
    MODIFY collection_fee INT NOT NULL,
    ADD CONSTRAINT chk_company_id
        CHECK (company_id > 0),
    ADD CONSTRAINT chk_collection_company_name
        CHECK (CHAR_LENGTH(TRIM(waste_collection_company_name)) > 0),
    ADD CONSTRAINT chk_collection_fee
        CHECK (collection_fee >= 0),
    ADD CONSTRAINT uq_collection_company_name
        UNIQUE (waste_collection_company_name),
    ADD CONSTRAINT fk_collection_company_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id);
        
-- 2. INSERT SAMPLE DATA

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
(4, 4, 'Nordic Timber Supply'),
(5, 5, 'French Silicon Solutions');

INSERT INTO material (material_id, material_name, material_type) VALUES
(1, 'Aluminium', 'Metal'),
(2, 'Copper', 'Metal'),
(3, 'Recycled Glass', 'Glass'),
(4, 'Recycled Timber', 'Wood'),
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
(4, 'Office Chair', 10),
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
(5, 'Exported for Recycling', 5);

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
(4, 'Salvaged Timber', 1),
(5, 'Silicon Wafer Processing', 2);

INSERT INTO extraction
(extraction_id, supplier_id, material_id, extraction_method_id,
 extraction_quantity)
VALUES
(1, 1, 1, 1, 120000),
(2, 2, 2, 2, 85000),
(3, 3, 3, 3, 95000),
(4, 4, 4, 4, 110000),
(5, 5, 5, 5, 78000);

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

-- Office Chair
(4, 4, 9000),

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

-- 3. CHECK THAT DATA WAS INSERTED

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