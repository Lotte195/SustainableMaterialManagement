-- In this file, we create a new table about prices for our database, and its attributes. 
-- We've also specified primary and foreign keys in here, and wrote down the datatypes.
-- We also insert some sample data

CREATE TABLE material_prices (
    country_id INT NOT NULL,
    material_id INT NOT NULL,
    process_type ENUM('extraction', 'recycling') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency CHAR(5) DEFAULT 'EUR',
    PRIMARY KEY (country_id, material_id, process_type),
    FOREIGN KEY (country_id)
        REFERENCES country(country_id),
    FOREIGN KEY (material_id)
        REFERENCES material(material_id)
);

INSERT INTO material_prices
    (country_id, material_id, process_type, price, currency)
VALUES

-- Netherlands
(1, 1, 'extraction', 100.00, 'EUR'),
(1, 1, 'recycling',   75.00, 'EUR'),
(1, 2, 'extraction', 150.00, 'EUR'),
(1, 2, 'recycling',  110.00, 'EUR'),
(1, 3, 'extraction', 200.00, 'EUR'),
(1, 3, 'recycling',  150.00, 'EUR'),
(1, 4, 'extraction',  75.00, 'EUR'),
(1, 4, 'recycling',   50.00, 'EUR'),
(1, 5, 'extraction', 125.00, 'EUR'),
(1, 5, 'recycling',   90.00, 'EUR'),

-- Germany
(2, 1, 'extraction',  95.00, 'EUR'),
(2, 1, 'recycling',   70.00, 'EUR'),
(2, 2, 'extraction', 145.00, 'EUR'),
(2, 2, 'recycling',  105.00, 'EUR'),
(2, 3, 'extraction', 195.00, 'EUR'),
(2, 3, 'recycling',  145.00, 'EUR'),
(2, 4, 'extraction',  70.00, 'EUR'),
(2, 4, 'recycling',   48.00, 'EUR'),
(2, 5, 'extraction', 120.00, 'EUR'),
(2, 5, 'recycling',   85.00, 'EUR'),

-- Belgium
(3, 1, 'extraction',  98.00, 'EUR'),
(3, 1, 'recycling',   73.00, 'EUR'),
(3, 2, 'extraction', 148.00, 'EUR'),
(3, 2, 'recycling',  108.00, 'EUR'),
(3, 3, 'extraction', 198.00, 'EUR'),
(3, 3, 'recycling',  148.00, 'EUR'),
(3, 4, 'extraction',  73.00, 'EUR'),
(3, 4, 'recycling',   51.00, 'EUR'),
(3, 5, 'extraction', 123.00, 'EUR'),
(3, 5, 'recycling',   88.00, 'EUR'),

-- Sweden
(4, 1, 'extraction', 105.00, 'EUR'),
(4, 1, 'recycling',   78.00, 'EUR'),
(4, 2, 'extraction', 155.00, 'EUR'),
(4, 2, 'recycling',  115.00, 'EUR'),
(4, 3, 'extraction', 210.00, 'EUR'),
(4, 3, 'recycling',  155.00, 'EUR'),
(4, 4, 'extraction',  80.00, 'EUR'),
(4, 4, 'recycling',   55.00, 'EUR'),
(4, 5, 'extraction', 130.00, 'EUR'),
(4, 5, 'recycling',   95.00, 'EUR'),

-- France
(5, 1, 'extraction', 102.00, 'EUR'),
(5, 1, 'recycling',   76.00, 'EUR'),
(5, 2, 'extraction', 152.00, 'EUR'),
(5, 2, 'recycling',  112.00, 'EUR'),
(5, 3, 'extraction', 202.00, 'EUR'),
(5, 3, 'recycling',  152.00, 'EUR'),
(5, 4, 'extraction',  76.00, 'EUR'),
(5, 4, 'recycling',   53.00, 'EUR'),
(5, 5, 'extraction', 127.00, 'EUR'),
(5, 5, 'recycling',   92.00, 'EUR');