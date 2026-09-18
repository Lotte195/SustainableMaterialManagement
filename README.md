# SustainableMaterialManagement

SQL code for a database that keeps track of materials used in technology products and their recycling.

## ERD

For an overview of the Entity-Relationship Diagram (ERD) of this database, see the [Lucidchart ERD](https://lucid.app/lucidchart/7d0e5de8-1718-480a-b3a6-82ad701c2c3a/edit?viewport_loc=-2409%2C-3470%2C4249%2C1937%2C0_0&invitationId=inv_c4767de5-4d50-4759-bf8f-d591fd471b6a).

## About the Project

Material scarcity in technology production is an economic and environmental problem. High product costs, resource extraction that damages the environment, and waste accumulation are examples of the negative effects associated with high levels of production.

This database attempts to keep track of factories, production, material extraction, recycling, waste collection, and related information.

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

## Getting Started


1. Clone this repository.
2. Open MySQL Workbench and connect to your MySQL server.
3. Open `sql/schema.sql` and execute it to create the database structure.
4. Open `sql/sample_data.sql` and execute it to insert the example data. (This file also contains the CONSTRAINTS)
5. Select the `SustainableMaterialManagement` database and start querying.

## Project Structure

```text
SustainableMaterialManagement/
│
├── README.md
│
└── sql/
    ├── schema.sql
    ├── sample_data.sql
    └── queries.sql
```

### SQL Files

* `sql/schema.sql` — Database structure, including tables, primary keys, and foreign keys.
* `sql/sample_data.sql` — Example data for the database, and the constraints (we put the constraints separate from the schema so that you don't need to recreate the database if you want to change something about the constraints.
* `sql/queries.sql` — Example queries for analysing the database.
