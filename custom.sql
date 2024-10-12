CREATE USER anon;

COMMIT;

GRANT USAGE ON SCHEMA public TO anon;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT
SELECT
    ON TABLES TO anon;

GRANT
SELECT
    ON ALL SEQUENCES IN SCHEMA public TO anon;

GRANT
SELECT
    ON ALL TABLES IN SCHEMA public TO anon;

CREATE table
    IF NOT EXISTS pets (
        id serial NOT NULL,
        name text NOT NULL,
        breed text NOT NULL,
        age int4 NOT NULL,
        owner text NOT NULL
    );

COMMIT;

INSERT INTO
    pets (name, breed, age, owner)
VALUES
    ('Buddy', 'Golden Retriever', 3, 'John Doe'),
    ('Lucy', 'Labrador', 5, 'Jane Smith'),
    ('Charlie', 'Poodle', 2, 'Alice Johnson'),
    ('Daisy', 'Boxer', 4, 'Mike Brown'),
    ('Max', 'Beagle', 6, 'Sarah White');