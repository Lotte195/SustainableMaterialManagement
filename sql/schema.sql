CREATE DATABASE IF NOT EXISTS SustainableMaterialManagement;
USE SustainableMaterialManagement;

CREATE TABLE country (
  country_id INT,
  country_name VARCHAR(50),
  PRIMARY KEY (country_id)
);

CREATE TABLE factory (
  factory_id INT,
  factory_name VARCHAR(50),
  country_id INT,
  PRIMARY KEY (factory_id),
  FOREIGN KEY (country_id)
      REFERENCES country(country_id)
);

CREATE TABLE supplier (
  supplier_id INT,
  country_id INT,
  supplier_name VARCHAR(50),
  PRIMARY KEY (supplier_id),
  FOREIGN KEY (country_id)
      REFERENCES country(country_id)
);

CREATE TABLE material (
  material_id INT,
  material_name VARCHAR(50),
  material_type VARCHAR(50),
  PRIMARY KEY (material_id)
);

CREATE TABLE recycling_company (
  recycling_company_id INT,
  country_id INT,
  recycling_company_name VARCHAR(50),
  recycling_efficiency_rate INT,
  PRIMARY KEY (recycling_company_id),
  FOREIGN KEY (country_id)
      REFERENCES country(country_id)
);

CREATE TABLE product_type (
  product_type_id INT,
  product_type_name VARCHAR(50),
  avg_lifespan_years INT,
  PRIMARY KEY (product_type_id)
);

CREATE TABLE waste_collection_rule (
  rule_id INT,
  country_id INT,
  rule_description VARCHAR(50),
  PRIMARY KEY (rule_id),
  FOREIGN KEY (country_id)
      REFERENCES country(country_id)
);

CREATE TABLE product_fate (
  fate_id INT,
  fate_type VARCHAR(50),
  rule_id INT,
  PRIMARY KEY (fate_id),
  FOREIGN KEY (rule_id)
    REFERENCES waste_collection_rule(rule_id)

);

CREATE TABLE waste_record (
  waste_record_id INT,
  product_type_id INT,
  country_id INT,
  fate_id INT,
  percent_collected INT,
  percent_illegal INT,
  quantity_collected INT,
  PRIMARY KEY (waste_record_id),
  FOREIGN KEY (product_type_id)
      REFERENCES product_type(product_type_id),
  FOREIGN KEY (country_id)
      REFERENCES country(country_id),
  FOREIGN KEY (fate_id)
      REFERENCES product_fate(fate_id)
);

CREATE TABLE recovery (
  recovery_id INT,
  waste_record_id INT,
  recycling_company_id INT,
  quantity_recovered INT,
  recover_rate_percent INT,
  PRIMARY KEY (recovery_id),
  FOREIGN KEY (waste_record_id)
      REFERENCES waste_record(waste_record_id),
  FOREIGN KEY (recycling_company_id)
      REFERENCES recycling_company(recycling_company_id)
);

CREATE TABLE factory_product (
  factory_product_id INT,
  factory_id INT,
  product_type_id INT,
  PRIMARY KEY (factory_product_id),
  FOREIGN KEY (factory_id)
      REFERENCES factory(factory_id),
  FOREIGN KEY (product_type_id)
      REFERENCES product_type(product_type_id)
);

CREATE TABLE extraction_method (
  extraction_method_id INT,
  method_name VARCHAR(50),
  environmental_risk_rating INT,
  PRIMARY KEY (extraction_method_id)
);

CREATE TABLE extraction (
  extraction_id INT,
  supplier_id INT,
  material_id INT,
  extraction_method_id INT,
  extraction_quantity INT,
  PRIMARY KEY (extraction_id),
  FOREIGN KEY (supplier_id)
      REFERENCES supplier(supplier_id),
  FOREIGN KEY (material_id)
      REFERENCES material(material_id),
  FOREIGN KEY (extraction_method_id)
      REFERENCES extraction_method(extraction_method_id)
);

CREATE TABLE product_material (
  product_type_id INT,
  material_id INT,
  quantity_per_unit INT,
  PRIMARY KEY (product_type_id, material_id),
  FOREIGN KEY (product_type_id)
      REFERENCES product_type(product_type_id),
  FOREIGN KEY (material_id)
      REFERENCES material(material_id)
);

CREATE TABLE waste_collection_company (
  company_id INT,
  country_id INT,
  waste_collection_company_name VARCHAR(50),
  collection_fee INT,
  PRIMARY KEY (company_id),
  FOREIGN KEY (country_id)
      REFERENCES country(country_id)
);
