USE SustainableMaterialManagement;

-- ============================================================
-- REAL-WORLD DATA, reference year 2023
--
-- Source A: Eurostat env_waseleeos — Waste from Electrical and
--   Electronic Equipment (WEEE) by waste management operations,
--   open scope, 6 product categories. Category used here: Small
--   IT and telecommunications equipment (EE_SITTE), used as the
--   real-world proxy for product_type_id = 1 (Smartphone).
--   https://ec.europa.eu/eurostat/databrowser/view/env_waseleeos/default/table?lang=en
--   Last data update: 08/04/2026. License: Eurostat reuse policy
--
-- Source B: Eurostat env_ac_mfa — Material flow accounts,
--   Domestic Material Consumption (NOTE: this is DMC, not strict
--   Domestic Extraction -- DMC = extraction + imports - exports.
--   Used as the closest available proxy for the `material` /
--   `extraction` tables since this was the view exported.
--   Categories used: Biomass, Metal ores (gross ores),
--   Non-metallic minerals, Fossil energy materials/carriers
--   ('Total' column skipped -- it's a derived sum, not a unique
--   observation).
--   https://ec.europa.eu/eurostat/databrowser/view/env_ac_mfa/default/table?lang=en
--   Last data update: 02/07/2026. Same Eurostat reuse policy.

-- ----------------------------------
-- INTEGRATION WORK
-- ----------------------------------
-- Eurostat has missing values maked with :. Those cells were left 
-- out of the INSERT statements rather than inserted as 0.

-- Country names differ from spelling conventions already used in  
-- the database (e.g. Eurostat's "Czechia" vs. the more common  
-- "Czech Republic"), so names were normalized/mapped to match 
-- existing country table entries before inserting.

-- ------------------------------------------------------------
-- SCHEMA FIXES REQUIRED BY REAL DATA (run once, before inserts)
-- ------------------------------------------------------------

-- 1. NORMALIZATION FIX: product_fate was tied to a single
--    country's rule via rule_id, making a fate type like
--    'Recycled' unusable across multiple countries. Decoupled:
ALTER TABLE product_fate DROP FOREIGN KEY fk_fate_rule;
ALTER TABLE product_fate DROP COLUMN rule_id;

-- 2. percent_collected / percent_illegal: Eurostat does not
--    report a collection-rate percentage for most countries,
--    and never reports an illegal-disposal percentage at all.
--    DROP CHECK (not DROP CONSTRAINT) -- version-safe for all
--    MySQL 8.0.16+, DROP CONSTRAINT only works from 8.0.19+.
ALTER TABLE waste_record
    DROP CHECK chk_percent_collected,
    DROP CHECK chk_percent_illegal,
    DROP CHECK chk_percent_total,
    MODIFY percent_collected INT NULL,
    MODIFY percent_illegal INT NULL,
    ADD CONSTRAINT chk_percent_collected
        CHECK (percent_collected IS NULL OR percent_collected BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_percent_illegal
        CHECK (percent_illegal IS NULL OR percent_illegal BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_percent_total
        CHECK (percent_illegal IS NULL
               OR percent_collected + percent_illegal <= 100);

-- 3. extraction_quantity: MFA figures are in thousand tonnes
--    with up to 3 decimal places; INT would truncate them.
ALTER TABLE extraction
    MODIFY extraction_quantity DECIMAL(14,3) NOT NULL;

-- 4. extraction.supplier_id: MFA has no supplier-level detail,
--    only country-level totals. Relaxed to NULL.
ALTER TABLE extraction
    MODIFY supplier_id INT NULL;

-- 5. recycling_efficiency_rate: real recovery rates can exceed
--    100% due to stock changes / cross-border movements in the
--    underlying statistics (e.g. Czechia 2023 = 104.3%). This is
--    a genuine, documented statistical phenomenon, not bad data,
--    so we widen the range rather than silently capping it.
ALTER TABLE recycling_company
    DROP CHECK chk_recycling_efficiency,
    ADD CONSTRAINT chk_recycling_efficiency
        CHECK (recycling_efficiency_rate BETWEEN 0 AND 150);
        
-- Changes recovery to go above 100, for exceptional cases
ALTER TABLE recovery
    DROP CHECK chk_recovery_rate,
    ADD CONSTRAINT chk_recovery_rate
        CHECK (recover_rate_percent BETWEEN 0 AND 150);

-- Allow for decimal values and 0
ALTER TABLE extraction
    MODIFY extraction_quantity DECIMAL(15,5) NOT NULL,
    DROP CHECK chk_extraction_quantity,
    ADD CONSTRAINT chk_extraction_quantity
        CHECK (extraction_quantity >= 0);

-- 6. Placeholder extraction method: MFA has no method-of-
--    extraction detail (open-pit vs underground, etc.)
INSERT INTO extraction_method (extraction_method_id, method_name, environmental_risk_rating)
VALUES (6, 'Not specified (Eurostat aggregate)', 3);

-- ------------------------------------------------------------
-- DATA
-- ------------------------------------------------------------

-- New countries from the real data (31 rows; Netherlands/Germany/Belgium/Sweden/France already existed)
INSERT INTO country
(country_id, country_name)
VALUES
(100, 'Bulgaria'),
(101, 'Czechia'),
(102, 'Denmark'),
(103, 'Estonia'),
(104, 'Ireland'),
(105, 'Greece'),
(106, 'Spain'),
(107, 'Croatia'),
(108, 'Italy'),
(109, 'Cyprus'),
(110, 'Latvia'),
(111, 'Lithuania'),
(112, 'Luxembourg'),
(113, 'Hungary'),
(114, 'Malta'),
(115, 'Austria'),
(116, 'Poland'),
(117, 'Portugal'),
(118, 'Slovenia'),
(119, 'Slovakia'),
(120, 'Finland'),
(121, 'Liechtenstein'),
(122, 'Norway'),
(123, 'Romania'),
(124, 'Iceland'),
(125, 'Switzerland'),
(126, 'Bosnia and Herzegovina'),
(127, 'North Macedonia'),
(128, 'Albania'),
(129, 'Serbia'),
(130, 'Türkiye'),
(131, 'Netherlands'),
(132, 'Germany'),
(133, 'Belgium'),
(134, 'Sweden'),
(135, 'France'),
(136, 'European Union');

INSERT INTO factory (factory_id, factory_name, country_id) VALUES
(1, 'Eindhoven Electronics Plant', 131),
(2, 'Munich Battery Works', 132),
(3, 'Antwerp Appliance Factory', 133),
(4, 'Malmo Furniture Works', 134),
(5, 'Lyon Electronic Basics', 135);

INSERT INTO supplier (supplier_id, country_id, supplier_name) VALUES
(1, 131, 'Dutch Metals Supply'),
(2, 132, 'Bavaria Raw Materials'),
(3, 133, 'Belgian Glass Partners'),
(4, 134, 'Nordic Gold Mine'),
(5, 135, 'French Silicon Solutions');

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
(1, 131, 'Separate electronics collection'),
(2, 132, 'Certified e-waste collection'),
(3, 133, 'Municipal recycling required'),
(4, 134, 'Producer take-back system'),
(5, 135, 'Household recycling points');

-- Material categories (Eurostat MFA top-level breakdown)
INSERT INTO material
(material_id, material_name, material_type)
VALUES
(100, 'Biomass', 'MFA category'),
(101, 'Metal ores (gross ores)', 'MFA category'),
(102, 'Non-metallic minerals', 'MFA category'),
(103, 'Fossil energy materials/carriers', 'MFA category');

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

-- THIS DATA DOES NOT MATCH!!!
INSERT INTO product_material
(product_type_id, material_id, quantity_per_unit)
VALUES
-- Smartphone
(1, 100, 120),
(1, 102, 25),

-- Laptop
(2, 100, 850),
(2, 102, 180),

-- Washing Machine
(3, 100, 4200),

-- CPU
(4, 100, 90),
(4, 103, 120),
(4, 101, 25),

-- Microchip
(5, 100, 20),
(5, 102, 5),
(5, 101, 2);

INSERT INTO waste_collection_company
(company_id, country_id, waste_collection_company_name, collection_fee)
VALUES
(1, 131, 'Amsterdam Waste Services', 25),
(2, 132, 'Berlin Circular Collection', 30),
(3, 133, 'Brussels Eco Collection', 22),
(4, 134, 'Stockholm Waste Solutions', 28),
(5, 135, 'Paris Recycling Services', 24);

-- Fate types -- now a reusable lookup, not tied to one country
INSERT INTO product_fate
(fate_id, fate_type)
VALUES
(100, 'Collected'),
(101, 'Treated'),
(102, 'Recovered'),
(103, 'Recycled and prepared for reuse'),
(104, 'Recycled');

-- National WEEE recovery systems -- one placeholder per country
-- where a real recovery-rate percentage was available (28 rows)
INSERT INTO recycling_company
(recycling_company_id, country_id, recycling_company_name, recycling_efficiency_rate)
VALUES
(100, 136, 'National WEEE recovery system – European Union - 27 countries (from 2020)', 89),
(101, 133, 'National WEEE recovery system – Belgium', 86),
(102, 100, 'National WEEE recovery system – Bulgaria', 84),
(103, 101, 'National WEEE recovery system – Czechia', 104),
(104, 102, 'National WEEE recovery system – Denmark', 20),
(105, 132, 'National WEEE recovery system – Germany', 99),
(106, 103, 'National WEEE recovery system – Estonia', 98),
(107, 104, 'National WEEE recovery system – Ireland', 98),
(108, 105, 'National WEEE recovery system – Greece', 92),
(109, 106, 'National WEEE recovery system – Spain', 82),
(110, 135, 'National WEEE recovery system – France', 88),
(111, 107, 'National WEEE recovery system – Croatia', 86),
(112, 108, 'National WEEE recovery system – Italy', 74),
(113, 109, 'National WEEE recovery system – Cyprus', 88),
(114, 110, 'National WEEE recovery system – Latvia', 79),
(115, 111, 'National WEEE recovery system – Lithuania', 83),
(116, 112, 'National WEEE recovery system – Luxembourg', 95),
(117, 113, 'National WEEE recovery system – Hungary', 70),
(118, 114, 'National WEEE recovery system – Malta', 90),
(119, 131, 'National WEEE recovery system – Netherlands', 98),
(120, 115, 'National WEEE recovery system – Austria', 96),
(121, 116, 'National WEEE recovery system – Poland', 100),
(122, 117, 'National WEEE recovery system – Portugal', 98),
(123, 118, 'National WEEE recovery system – Slovenia', 95),
(124, 119, 'National WEEE recovery system – Slovakia', 94),
(125, 120, 'National WEEE recovery system – Finland', 93),
(126, 121, 'National WEEE recovery system – Liechtenstein', 73),
(127, 122, 'National WEEE recovery system – Norway', 93);

-- Waste records from WEEE data (140 rows, one per country x operation observed)
INSERT INTO waste_record
(waste_record_id, product_type_id, country_id, fate_id, percent_collected, percent_illegal, quantity_collected)
VALUES
(1000, 1, 136, 100, NULL, NULL, 341042),
(1001, 1, 136, 101, NULL, NULL, 322662),
(1002, 1, 136, 102, NULL, NULL, 303873),
(1003, 1, 136, 103, NULL, NULL, 265125),
(1004, 1, 136, 104, NULL, NULL, 252635),
(1005, 1, 133, 100, NULL, NULL, 24099),
(1006, 1, 133, 101, NULL, NULL, 24095),
(1007, 1, 133, 102, NULL, NULL, 20706),
(1008, 1, 133, 103, NULL, NULL, 18504),
(1009, 1, 133, 104, NULL, NULL, 16895),
(1010, 1, 100, 100, NULL, NULL, 3370),
(1011, 1, 100, 101, NULL, NULL, 3314),
(1012, 1, 100, 102, NULL, NULL, 2830),
(1013, 1, 100, 103, NULL, NULL, 2810),
(1014, 1, 100, 104, NULL, NULL, 2810),
(1015, 1, 101, 100, NULL, NULL, 6242),
(1016, 1, 101, 101, NULL, NULL, 6800),
(1017, 1, 101, 102, NULL, NULL, 6513),
(1018, 1, 101, 103, NULL, NULL, 6343),
(1019, 1, 101, 104, NULL, NULL, 5855),
(1020, 1, 102, 100, NULL, NULL, 13216),
(1021, 1, 102, 101, NULL, NULL, 1080),
(1022, 1, 102, 102, NULL, NULL, 2666),
(1023, 1, 102, 103, NULL, NULL, 679),
(1024, 1, 102, 104, NULL, NULL, 679),
(1025, 1, 132, 100, NULL, NULL, 90967),
(1026, 1, 132, 101, NULL, NULL, 90967),
(1027, 1, 132, 102, NULL, NULL, 89829),
(1028, 1, 132, 103, NULL, NULL, 75601),
(1029, 1, 132, 104, NULL, NULL, 73635),
(1030, 1, 103, 100, NULL, NULL, 915),
(1031, 1, 103, 101, NULL, NULL, 915),
(1032, 1, 103, 102, NULL, NULL, 892),
(1033, 1, 103, 103, NULL, NULL, 845),
(1034, 1, 103, 104, NULL, NULL, 845),
(1035, 1, 104, 100, NULL, NULL, 5265),
(1036, 1, 104, 101, NULL, NULL, 5265),
(1037, 1, 104, 102, NULL, NULL, 5172),
(1038, 1, 104, 103, NULL, NULL, 4691),
(1039, 1, 104, 104, NULL, NULL, 4517),
(1040, 1, 105, 100, NULL, NULL, 3217),
(1041, 1, 105, 101, NULL, NULL, 3222),
(1042, 1, 105, 102, NULL, NULL, 2944),
(1043, 1, 105, 103, NULL, NULL, 2047),
(1044, 1, 105, 104, NULL, NULL, 1942),
(1045, 1, 106, 100, 40, NULL, 15280),
(1046, 1, 106, 101, NULL, NULL, 13828),
(1047, 1, 106, 102, NULL, NULL, 12548),
(1048, 1, 106, 103, NULL, NULL, 12455),
(1049, 1, 106, 104, NULL, NULL, 12347),
(1050, 1, 135, 100, NULL, NULL, 56605),
(1051, 1, 135, 101, NULL, NULL, 52872),
(1052, 1, 135, 102, NULL, NULL, 49979),
(1053, 1, 135, 103, NULL, NULL, 43062),
(1054, 1, 135, 104, NULL, NULL, 38942),
(1055, 1, 107, 100, NULL, NULL, 2023),
(1056, 1, 107, 101, NULL, NULL, 1739),
(1057, 1, 107, 102, NULL, NULL, 1739),
(1058, 1, 107, 103, NULL, NULL, 1739),
(1059, 1, 107, 104, NULL, NULL, 1739),
(1060, 1, 108, 100, NULL, NULL, 19920),
(1061, 1, 108, 101, NULL, NULL, 18403),
(1062, 1, 108, 102, NULL, NULL, 14776),
(1063, 1, 108, 103, NULL, NULL, 12150),
(1064, 1, 108, 104, NULL, NULL, 9445),
(1065, 1, 109, 100, 45, NULL, 382),
(1066, 1, 109, 101, NULL, NULL, 382),
(1067, 1, 109, 102, NULL, NULL, 335),
(1068, 1, 109, 103, NULL, NULL, 335),
(1069, 1, 109, 104, NULL, NULL, 333),
(1070, 1, 110, 100, NULL, NULL, 497),
(1071, 1, 110, 101, NULL, NULL, 489),
(1072, 1, 110, 102, NULL, NULL, 393),
(1073, 1, 110, 103, NULL, NULL, 370),
(1074, 1, 110, 104, NULL, NULL, 370),
(1075, 1, 111, 100, NULL, NULL, 1324),
(1076, 1, 111, 101, NULL, NULL, 1230),
(1077, 1, 111, 102, NULL, NULL, 1098),
(1078, 1, 111, 103, NULL, NULL, 1029),
(1079, 1, 111, 104, NULL, NULL, 1029),
(1080, 1, 112, 100, 53, NULL, 645),
(1081, 1, 112, 101, NULL, NULL, 645),
(1082, 1, 112, 102, NULL, NULL, 612),
(1083, 1, 112, 103, NULL, NULL, 548),
(1084, 1, 112, 104, NULL, NULL, 548),
(1085, 1, 113, 100, 77, NULL, 6623),
(1086, 1, 113, 101, NULL, NULL, 6096),
(1087, 1, 113, 102, NULL, NULL, 4645),
(1088, 1, 113, 103, NULL, NULL, 4582),
(1089, 1, 113, 104, NULL, NULL, 4582),
(1090, 1, 114, 100, NULL, NULL, 214),
(1091, 1, 114, 101, NULL, NULL, 194),
(1092, 1, 114, 102, NULL, NULL, 193),
(1093, 1, 114, 103, NULL, NULL, 190),
(1094, 1, 114, 104, NULL, NULL, 190),
(1095, 1, 131, 100, 73, NULL, 23409),
(1096, 1, 131, 101, NULL, NULL, 22873),
(1097, 1, 131, 102, NULL, NULL, 22873),
(1098, 1, 131, 103, NULL, NULL, 19254),
(1099, 1, 131, 104, NULL, NULL, 19254),
(1100, 1, 115, 100, NULL, NULL, 10702),
(1101, 1, 115, 101, NULL, NULL, 10702),
(1102, 1, 115, 102, NULL, NULL, 10293),
(1103, 1, 115, 103, NULL, NULL, 8488),
(1104, 1, 115, 104, NULL, NULL, 8408),
(1105, 1, 116, 100, 65, NULL, 20852),
(1106, 1, 116, 101, NULL, NULL, 20796),
(1107, 1, 116, 102, NULL, NULL, 20841),
(1108, 1, 116, 103, NULL, NULL, 19790),
(1109, 1, 116, 104, NULL, NULL, 18938),
(1110, 1, 117, 100, NULL, NULL, 7552),
(1111, 1, 117, 101, NULL, NULL, 7552),
(1112, 1, 117, 102, NULL, NULL, 7421),
(1113, 1, 117, 103, NULL, NULL, 6927),
(1114, 1, 117, 104, NULL, NULL, 6809),
(1115, 1, 118, 100, NULL, NULL, 1538),
(1116, 1, 118, 101, NULL, NULL, 3562),
(1117, 1, 118, 102, NULL, NULL, 1466),
(1118, 1, 118, 103, NULL, NULL, 1435),
(1119, 1, 118, 104, NULL, NULL, 1434),
(1120, 1, 119, 100, NULL, NULL, 5064),
(1121, 1, 119, 101, NULL, NULL, 4987),
(1122, 1, 119, 102, NULL, NULL, 4745),
(1123, 1, 119, 103, NULL, NULL, 4668),
(1124, 1, 119, 104, NULL, NULL, 4661),
(1125, 1, 120, 100, 48, NULL, 4020),
(1126, 1, 120, 101, NULL, NULL, 4019),
(1127, 1, 120, 102, NULL, NULL, 3737),
(1128, 1, 120, 103, NULL, NULL, 3554),
(1129, 1, 120, 104, NULL, NULL, 3438),
(1130, 1, 121, 100, NULL, NULL, 86),
(1131, 1, 121, 101, NULL, NULL, 86),
(1132, 1, 121, 102, NULL, NULL, 62),
(1133, 1, 121, 103, NULL, NULL, 62),
(1134, 1, 121, 104, NULL, NULL, 62),
(1135, 1, 122, 100, NULL, NULL, 7830),
(1136, 1, 122, 101, NULL, NULL, 7700),
(1137, 1, 122, 102, NULL, NULL, 7304),
(1138, 1, 122, 103, NULL, NULL, 6187),
(1139, 1, 122, 104, NULL, NULL, 4908);

-- Recovery records (28 rows)
INSERT INTO recovery
(recovery_id, waste_record_id, recycling_company_id, quantity_recovered, recover_rate_percent)
VALUES
(1000, 1000, 100, 303873, 89),
(1001, 1005, 101, 20706, 86),
(1002, 1010, 102, 2830, 84),
(1003, 1015, 103, 6513, 104),
(1004, 1020, 104, 2666, 20),
(1005, 1025, 105, 89829, 99),
(1006, 1030, 106, 892, 98),
(1007, 1035, 107, 5172, 98),
(1008, 1040, 108, 2944, 92),
(1009, 1045, 109, 12548, 82),
(1010, 1050, 110, 49979, 88),
(1011, 1055, 111, 1739, 86),
(1012, 1060, 112, 14776, 74),
(1013, 1065, 113, 335, 88),
(1014, 1070, 114, 393, 79),
(1015, 1075, 115, 1098, 83),
(1016, 1080, 116, 612, 95),
(1017, 1085, 117, 4645, 70),
(1018, 1090, 118, 193, 90),
(1019, 1095, 119, 22873, 98),
(1020, 1100, 120, 10293, 96),
(1021, 1105, 121, 20841, 100),
(1022, 1110, 122, 7421, 98),
(1023, 1115, 123, 1466, 95),
(1024, 1120, 124, 4745, 94),
(1025, 1125, 125, 3737, 93),
(1026, 1130, 126, 62, 73),
(1027, 1135, 127, 7304, 93);

-- Extraction (Domestic extraction, thousand tonnes, reference year 2023) records

INSERT INTO extraction
(extraction_id, supplier_id, material_id, extraction_method_id, extraction_quantity)
VALUES
-- Belgium
(1000, NULL, 100, 6, 37274.212),
(1001, NULL, 101, 6, 0.000),
(1002, NULL, 102, 6, 51275.872),
(1003, NULL, 103, 6, 143.032),
-- Bulgaria
(1004, NULL, 100, 6, 27106.998),
(1005, NULL, 101, 6, 35521.125),
(1006, NULL, 102, 6, 66949.890),
(1007, NULL, 103, 6, 21035.796),
-- Czechia
(1008, NULL, 100, 6, 37750.658),
(1009, NULL, 101, 6, 0.000),
(1010, NULL, 102, 6, 75863.055),
(1011, NULL, 103, 6, 29815.640),
-- Denmark
(1012, NULL, 100, 6, 34647.631),
(1013, NULL, 101, 6, 0.000),
(1014, NULL, 102, 6, 61101.106),
(1015, NULL, 103, 6, 4093.399),
-- Germany
(1016, NULL, 100, 6, 231752.898),
(1017, NULL, 101, 6, 533.452),
(1018, NULL, 102, 6, 508907.114),
(1019, NULL, 103, 6, 110539.685),
-- Estonia
(1020, NULL, 100, 6, 10121.691),
(1021, NULL, 101, 6, 0.000),
(1022, NULL, 102, 6, 15878.301),
(1023, NULL, 103, 6, 11058.200),
-- Ireland
(1024, NULL, 100, 6, 41875.681),
(1025, NULL, 101, 6, 1092.678),
(1026, NULL, 102, 6, 52992.047),
(1027, NULL, 103, 6, 1229.232),
-- Greece
(1028, NULL, 100, 6, 24807.922),
(1029, NULL, 101, 6, 1475.867),
(1030, NULL, 102, 6, 57666.305),
(1031, NULL, 103, 6, 10823.260),
-- Spain
(1032, NULL, 100, 6, 104506.167),
(1033, NULL, 101, 6, 23233.159),
(1034, NULL, 102, 6, 219865.976),
(1035, NULL, 103, 6, 110.206),
-- France
(1036, NULL, 100, 6, 261333.212),
(1037, NULL, 101, 6, 203.588),
(1038, NULL, 102, 6, 366659.823),
(1039, NULL, 103, 6, 612.700),
-- Croatia
(1040, NULL, 100, 6, 14082.000),
(1041, NULL, 101, 6, 0.000),
(1042, NULL, 102, 6, 26963.000),
(1043, NULL, 103, 6, 1170.000),
-- Italy
(1044, NULL, 100, 6, 113012.512),
(1045, NULL, 101, 6, 86.874),
(1046, NULL, 102, 6, 224446.409),
(1047, NULL, 103, 6, 6220.000),
-- Cyprus
(1048, NULL, 100, 6, 611.123),
(1049, NULL, 101, 6, 0.000),
(1050, NULL, 102, 6, 14863.061),
(1051, NULL, 103, 6, 0.000),
-- Latvia
(1052, NULL, 100, 6, 16673.018),
(1053, NULL, 101, 6, 0.000),
(1054, NULL, 102, 6, 15367.197),
(1055, NULL, 103, 6, 1467.370),
-- Lithuania
(1056, NULL, 100, 6, 22178.744),
(1057, NULL, 101, 6, 0.000),
(1058, NULL, 102, 6, 33918.360),
(1059, NULL, 103, 6, 513.525),
-- Luxembourg
(1060, NULL, 100, 6, 1841.422),
(1061, NULL, 101, 6, 0.000),
(1062, NULL, 102, 6, 485.378),
(1063, NULL, 103, 6, 0.000),
-- Hungary
(1064, NULL, 100, 6, 43987.840),
(1065, NULL, 101, 6, 0.000),
(1066, NULL, 102, 6, 70187.231),
(1067, NULL, 103, 6, 6404.198),
-- Malta
(1068, NULL, 100, 6, 93.187),
(1069, NULL, 101, 6, 0.000),
(1070, NULL, 102, 6, 1633.810),
(1071, NULL, 103, 6, 0.000),
-- Netherlands
(1072, NULL, 100, 6, 42011.757),
(1073, NULL, 101, 6, 0.000),
(1074, NULL, 102, 6, 27122.779),
(1075, NULL, 103, 6, 9815.966),
-- Austria
(1076, NULL, 100, 6, 36465.338),
(1077, NULL, 101, 6, 4799.794),
(1078, NULL, 102, 6, 78095.531),
(1079, NULL, 103, 6, 893.611),
-- Poland
(1080, NULL, 100, 6, 170102.870),
(1081, NULL, 101, 6, 30372.000),
(1082, NULL, 102, 6, 308442.728),
(1083, NULL, 103, 6, 94347.597),
-- Portugal
(1084, NULL, 100, 6, 28044.306),
(1085, NULL, 101, 6, 8306.084),
(1086, NULL, 102, 6, 103441.838),
(1087, NULL, 103, 6, 0.000),
-- Romania
(1088, NULL, 100, 6, 64857.300),
(1089, NULL, 101, 6, 3750.000),
(1090, NULL, 102, 6, 433552.931),
(1091, NULL, 103, 6, 24687.409),
-- Slovenia
(1092, NULL, 100, 6, 6465.411),
(1093, NULL, 101, 6, 0.000),
(1094, NULL, 102, 6, 17177.642),
(1095, NULL, 103, 6, 2574.742),
-- Slovakia
(1096, NULL, 100, 6, 19331.841),
(1097, NULL, 101, 6, 53.050),
(1098, NULL, 102, 6, 33689.720),
(1099, NULL, 103, 6, 807.000),
-- Finland
(1100, NULL, 100, 6, 45995.639),
(1101, NULL, 101, 6, 33540.556),
(1102, NULL, 102, 6, 136982.795),
(1103, NULL, 103, 6, 2198.800),
-- Sweden
(1104, NULL, 100, 6, 63153.979),
(1105, NULL, 101, 6, 83410.000),
(1106, NULL, 102, 6, 94160.965),
(1107, NULL, 103, 6, 618.300),
-- Iceland
(1108, NULL, 100, 6, 1983.224),
(1109, NULL, 101, 6, 0.000),
(1110, NULL, 102, 6, 2351.746),
(1111, NULL, 103, 6, 0.000),
-- Norway
(1112, NULL, 100, 6, 15225.660),
(1113, NULL, 101, 6, 2480.000),
(1114, NULL, 102, 6, 90399.000),
(1115, NULL, 103, 6, 213848.000),
-- Switzerland
(1116, NULL, 100, 6, 13331.106),
(1117, NULL, 101, 6, 0.000),
(1118, NULL, 102, 6, 39770.360),
(1119, NULL, 103, 6, 0.000),
-- Bosnia and Herzegovina
(1120, NULL, 100, 6, 7214.141),
(1121, NULL, 101, 6, 2194.732),
(1122, NULL, 102, 6, 12979.489),
(1123, NULL, 103, 6, 12791.560),
-- North Macedonia
(1124, NULL, 100, 6, 3686.521),
(1125, NULL, 101, 6, 5286.991),
(1126, NULL, 102, 6, 2254.486),
(1127, NULL, 103, 6, 5287.488),
-- Albania
(1128, NULL, 100, 6, 6753.414),
(1129, NULL, 101, 6, 1624.079),
(1130, NULL, 102, 6, 10845.112),
(1131, NULL, 103, 6, 1225.456),
-- Serbia
(1132, NULL, 100, 6, 37708.556),
(1133, NULL, 101, 6, 42143.652),
(1134, NULL, 102, 6, 39763.058),
(1135, NULL, 103, 6, 32995.569),
-- Türkiye
(1136, NULL, 100, 6, 274593.100),
(1137, NULL, 101, 6, 62489.300),
(1138, NULL, 102, 6, 497692.100),
(1139, NULL, 103, 6, 79042.900);
-- Row count check
SELECT 'country' AS table_name, COUNT(*) AS row_count FROM country
UNION ALL
SELECT 'product_fate' AS table_name, COUNT(*) AS row_count FROM product_fate
UNION ALL
SELECT 'material' AS table_name, COUNT(*) AS row_count FROM material
UNION ALL
SELECT 'recycling_company' AS table_name, COUNT(*) AS row_count FROM recycling_company
UNION ALL
SELECT 'waste_record' AS table_name, COUNT(*) AS row_count FROM waste_record
UNION ALL
SELECT 'recovery' AS table_name, COUNT(*) AS row_count FROM recovery
UNION ALL
SELECT 'extraction' AS table_name, COUNT(*) AS row_count FROM extraction;
