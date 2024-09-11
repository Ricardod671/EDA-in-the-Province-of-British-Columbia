-- Creating the production table
CREATE TABLE production (
    id_production SERIAL PRIMARY KEY,
    id_well INT NOT NULL,
    production_date DATE NOT NULL,
    gas_prod_vol DECIMAL(10, 2) DEFAULT 0, -- Gas production volume (e3m3)
    oil_prod_vol DECIMAL(10, 2) DEFAULT 0, -- Oil production volume (m3)
    water_prod_vol DECIMAL(10, 2) DEFAULT 0, -- Water production volume (m3)
    cond_prod_vol DECIMAL(10, 2) DEFAULT 0  -- Condensate production volume (m3)
);



