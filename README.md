# SustainableMaterialManagement
SQL code for a database keeping track of materials used in tech products, and their recycling.

For an overview of the ERD of this database, follow this link: https://lucid.app/lucidchart/7d0e5de8-1718-480a-b3a6-82ad701c2c3a/edit?viewport_loc=-2409%2C-3470%2C4249%2C1937%2C0_0&invitationId=inv_c4767de5-4d50-4759-bf8f-d591fd471b6a 

Material scarcity in tech production is an economic and environmental problem. High product costs, resource mining that damages the environment, and waste accumulation are examples of the negative effect that the high production level has. This database attempts to keep track of factories, production, mining, recycling, and more. 

country
Stores countries

factory
Stores factories and their countries

supplier
Stores suppliers and their countries

material
Stores materials

recycling_company
Stores recycling companies and their countries

product_type
Stores product categories/types

product_fate
Stores possible waste destinations

waste_collection_rule
Stores country-specific collection rules

waste_record
Connects waste data to product types, countries, and fates

recovery
Connects waste records to recycling companies

factory_product
Junction table between factories and product types

extraction_method
Stores extraction methods

extraction
Connects suppliers, materials, and extraction methods
	
product_material
Junction table between product types and materials

waste_collection_company
Stores collection companies and their countries
