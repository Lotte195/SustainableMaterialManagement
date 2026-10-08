# SustainableMaterialManagement

SQL code for our database that keeps track of materials used in technology products and their recycling.


## About the Project

Material scarcity in technology production is an economic and environmental problem. High product costs, resource extraction that damages the environment, and waste accumulation are examples of the negative effects associated with high levels of production.

The database tracks the full lifecycle of tech metals in a Sustainable Material Management context: where materials are extracted, which products use them, where products are made, and what happens to them as waste . It should be able to answer questions like: Which countries and suppliers extract the most materials with high environmental risk?

## ERD

For an overview of the ERD of this database, see the [Lucidchart ERD](https://lucid.app/lucidchart/7d0e5de8-1718-480a-b3a6-82ad701c2c3a/edit?viewport_loc=-2409%2C-3470%2C4249%2C1937%2C0_0&invitationId=inv_c4767de5-4d50-4759-bf8f-d591fd471b6a), or see the same ERD via [PDF File](https://drive.google.com/file/d/156hH6o_Bom8cqUjlO8g0oECzve3xLdB1/view?usp=sharing). Please, download the file to see it in high resolution.
## ERD Description

### Data interactions

- A country hosts factories, suppliers, recycling companies, collection companies, and collection rules.
- A supplier performs extractions of materials using an extraction method.
- A factory produces many product types, and a product type is produced by many factories.
- A product type is composed of many materials, and a material is used in many product types.
- A product type generates waste records per country, and each waste record is assigned one fate (e.g. recycle, landfill).
- A fate is determined by collection rule.
- Recycling companies perform recoveries on waste records whose fate is "recycle".

### Entities

Country, factory, factory_product, supplier, material, extraction_method, extraction, product_type, waste_record, product_fate, product_type, waste_collection_rule, waste_collection_company, recycling_company, recovery.

### Relationships and cardinalities

- **Country → factory / supplier / recycling company / collection company / rule / waste record:** one-to-many (hosts).
- **Factory ↔ product_type:** many-to-many, resolved by `factory_product`.
- **Product_type ↔ material:** many-to-many (composed of), resolved by `product_material`.
- **Supplier ↔ material:** many-to-many (extracted via), resolved by `extraction`, which also links to `extraction_method`.
- **Product_type → waste_record:** one-to-many (generates).
- **Product_fate → waste_record:** one-to-many (assigned to).
- **Waste_collection_rule → product_fate:** one-to-many (determines).
- **Recycling_company → recover** one-to-many (performs)
- **Recover → material** one-to-many (recovers).
  
### Attributes and keys

Each table has its own PK. Bridge tables use either a composite PK or a surrogate PK.

## Database Tables

| Table                      | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| `country`                  | Stores countries                                           |
| `factory`                  | Stores factories and their countries                       |
| `supplier`                 | Stores suppliers and their countries                       |
| `material`                 | Stores materials                                           |
| `recycling_company`        | Stores recycling companies and their countries             |
| `product_type`             | Stores product categories/types                            |
| `product_fate`             | Stores possible waste destinations                         |
| `waste_collection_rule`    | Stores country-specific waste collection rules             |
| `waste_record`             | Connects waste data to product types, countries, and fates |
| `recovery`                 | Connects waste records to recycling companies              |
| `factory_product`          | Junction table between factories and product types         |
| `extraction_method`        | Stores extraction methods                                  |
| `extraction`               | Connects suppliers, materials, and extraction methods      |
| `product_material`         | Junction table between product types and materials         |
| `waste_collection_company` | Stores waste collection companies and their countries      |

## Running order

1. Open `sql/schema.sql` and execute it to create the database structure.
2. Open `sql/constraints.sql` and execute to implement all constraints.
3. Open `sql/real_data.sql` and execute to insert the real data (this also contains sample data because the real data did not cover all entities)
4. Select the `SustainableMaterialManagement` database and start querying.

## Project Structure

```text
SustainableMaterialManagement/
│
├── Normalization (Google Docs Link)
├── README.md
├── Relation Schema.mwb
├── Reflection & Future Directions
├── Societal Problem Definition (Google Docs Link)
├── Stakeholder Presentation (YouTube Link)
├── Query Results
|   ├── Results query 1.csv
|   ├── ...
|   └── Results query 11.csv
│
└── sql/
    ├── constraints.sql
    ├── queries.sql
    ├── real_data.sql
    ├── sample_data.sql
    └── schema.sql
```

### Files

* `sql/schema.sql` — Database structure, including tables, primary keys, and foreign keys. This was based on our ERD.
* `sql/constraints.sql`-  Constraints, we put the constraints separate from the schema so that you don't need to recreate the database if you want to change something about the constraints.
* `sql/sample_data.sql` — Example data for the database (mock data, made up by us)
* `sql/queries.sql` — The three advanced queries we needed to write, and their explanations. Also includes 8 additional SELECT queries, 2 per person contributing to the project.
* `sql/real_data.sql` — Contains real data and some of the sample data for the entities that were not covered by the real data.
* `Relational Schema.mwb` — Relational schema of the database (open in MySQL)
* `Reflection & Future Directions` — Google Drive link to our reflection and future directions.
* `Societal Problem Definition` — Google Drive link to a news article, explanation, and motivation of the societal problem.
* `Normalization` — Google Drive link to a file explaining the normalization steps of the database.
* `Stakeholder Presentation` — YouTube link to a video of a presentation of our database to stakeholders.
* `Query results` — Folder containing .csv file results for each query.

### Real-world data, reference year 2023

Source A: Eurostat env_waseleeos — Waste from Electrical and Electronic Equipment (WEEE) by waste management operations, open scope, 6 product categories. Category used here: Small IT and telecommunications equipment (EE_SITTE), used as the real-world proxy for product_type_id = 1 (Smartphone). https://ec.europa.eu/eurostat/databrowser/view/env_waseleeos/default/table?lang=en Last data update: 08/04/2026. License: Eurostat reuse policy (free reuse incl. commercial, with source acknowledgement).

Source B: Eurostat env_ac_mfa — Material flow accounts, Domestic Material Consumption (NOTE: this is DMC, not strict Domestic Extraction -- DMC = extraction + imports - exports. Used as the closest available proxy for the `material` / `extraction` tables since this was the view exported. Categories used: Biomass, Metal ores (gross ores), Non-metallic minerals, Fossil energy materials/carriers ('Total' column skipped -- it's a derived sum, not a unique observation). https://ec.europa.eu/eurostat/databrowser/view/env_ac_mfa/default/table?lang=en Last data update: 02/07/2026. Same Eurostat reuse policy.
