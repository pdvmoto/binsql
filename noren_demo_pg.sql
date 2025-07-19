
-- Table creation
CREATE TABLE t (
    id INTEGER PRIMARY KEY,
    data VARCHAR(100),
    last_operation VARCHAR(10)
);

-- Data initialization (PostgreSQL doesn't have DUAL or CONNECT BY)
INSERT INTO t (id, data)
SELECT generate_series(1, 5), 'init';

-- Procedure using MERGE (PostgreSQL 15+)
CREATE OR REPLACE PROCEDURE with_merge(p_id INT, p_data VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    MERGE INTO t AS target
    USING (SELECT p_id AS id, p_data AS data) AS source
    ON (target.id = source.id)
    WHEN MATCHED THEN
        UPDATE SET data = source.data,
                   last_operation = 'update'
    WHEN NOT MATCHED THEN
        INSERT (id, data, last_operation)
        VALUES (source.id, source.data, 'insert');
END;
$$;

-- Procedure using exception handling (mimicking Oracle's logic)
CREATE OR REPLACE PROCEDURE without_merge(p_id INT, p_data VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t (id, data, last_operation)
    VALUES (p_id, p_data, 'insert');
EXCEPTION
    WHEN unique_violation THEN
        UPDATE t
        SET data = p_data,
            last_operation = 'update'
        WHERE id = p_id;
END;
$$;

-- Execute procedures (use DO block in PostgreSQL for anonymous PL/pgSQL)
DO $$
BEGIN
    CALL with_merge(1, 'with_merge');
    CALL with_merge(6, 'with_merge');
    CALL without_merge(2, 'without_merge');
    CALL without_merge(7, 'without_merge');
END;
$$;

-- Query the final result
SELECT * FROM t ORDER BY id;

