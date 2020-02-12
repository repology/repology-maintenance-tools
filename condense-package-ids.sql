-- Cure for running out of package ids

BEGIN;

-- First, generate a list of free metapackage ids
CREATE TEMPORARY TABLE freeids ON COMMIT DROP AS
	SELECT id
		FROM generate_series(1, 1 + (select count(*) * 2 from packages)) AS id
		LEFT JOIN packages
		USING (id)
		WHERE packages.id IS NULL
		LIMIT (
			SELECT count(*) FROM packages
		);

-- Next, generate a mapping between old and new ids
CREATE TABLE idmap AS
	SELECT old.id as old, new.id as new
	FROM
	(SELECT id, row_number() over(order by effname) AS rn FROM packages) as old
	JOIN
	(SELECT id, row_number() over(order by id) AS rn FROM freeids) as new
	ON (old.rn = new.rn);

-- Index it for faster lookups
CREATE unique index on idmap(old);

-- Update ids in all relevant tables according to the mapping

UPDATE problems
SET package_id = (SELECT new FROM idmap WHERE old = package_id);

UPDATE packages
SET id = (SELECT new FROM idmap WHERE old = id);

-- Update sequence to generate smaller ids
SELECT setval('packages_id_seq', (SELECT max(id) from packages));

COMMIT;

-- Cleanup all garbage we've generated
VACUUM FULL packages;
