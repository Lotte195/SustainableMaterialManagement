-- In this file, we add constraints to the attributes, limiting maximum characters and which numbers can be added to the database
-- We separate the constraints from the creation of the database, so that they can still be changed later on if needed
-- Foreign keys cannot be changed or constrained after database creation, which is why they are deleted, constrained and added again here, while there is still no data in them

USE SustainableMaterialManagement;

ALTER TABLE country
    MODIFY country_id INT NOT NULL,
    MODIFY country_name VARCHAR(56) NOT NULL,
    ADD CONSTRAINT chk_country_id
        CHECK (country_id > 0), -- This was added because country_id is an INT, which can be, but shouldn't be, negative (The same reasoning was used for the other alterations)
    ADD CONSTRAINT chk_country_name
        CHECK (CHAR_LENGTH(TRIM(country_name)) > 0), -- TRIM is used here to trim the possible blank spaces before or after the country_name, giving us the actual character length (The same reasoning was used for the other alterations)
    ADD CONSTRAINT uq_country_name                   
        UNIQUE (TRIM(country_name)); -- For example, the country names "Netherlands" and "   Netherlands   " will not be false duplicates due to TRIM here

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
        UNIQUE (TRIM(factory_name)),
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
        UNIQUE (TRIM(supplier_name)),
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
        UNIQUE (TRIM(material_name));

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
        UNIQUE (TRIM(recycling_company_name)),
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
        UNIQUE (TRIM(product_type_name));

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
        UNIQUE (TRIM(method_name));

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
        UNIQUE (TRIM(waste_collection_company_name)),
    ADD CONSTRAINT fk_collection_company_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id);
