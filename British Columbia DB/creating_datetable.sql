-- Creating a datetable
CREATE TABLE datetable (
    days INTEGER,
    months INTEGER,
    years INTEGER,
    dates DATE PRIMARY KEY
);

-- Insertar los primeros días de cada mes desde 1952 hasta 2024
DO $$
DECLARE
    current_dates DATE := '1952-01-01';
BEGIN
    WHILE current_dates <= '2028-12-01' LOOP
        INSERT INTO datetable (days, months, years, dates) VALUES (EXTRACT(DAY FROM current_dates), EXTRACT(MONTH FROM current_dates), EXTRACT(YEAR FROM current_dates), current_dates);
        current_dates := current_dates + INTERVAL '1 month';
    END LOOP;
END $$;

SELECT *
FROM datetable;
