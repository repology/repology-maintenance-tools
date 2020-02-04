-- Because of our current uneffective update process, where database is
-- recreated from scrach on each update, metapackage ids are constantly
-- wasted and may run out.

-- To cope with that, here's a query for renumbering metapackages

BEGIN;

-- First, generate a list of free metapackage ids
CREATE TEMPORARY TABLE freeids ON COMMIT DROP AS
	SELECT id
		FROM generate_series(1000000, 1000000 + (select count(*) * 2 from metapackages)) AS id
		LEFT JOIN metapackages
		USING (id)
		WHERE metapackages.id IS NULL
		LIMIT (
			SELECT count(*) FROM metapackages
		);

-- Next, generate a mapping between old and new ids
CREATE TABLE idmap AS
	SELECT old.id as old, new.id as new
	FROM
	(SELECT id, row_number() over(order by effname) AS rn FROM metapackages) as old
	JOIN
	(SELECT id, row_number() over(order by id) AS rn FROM freeids) as new
	ON (old.rn = new.rn);

-- Index it for faster lookups
CREATE unique index on idmap(old);

-- Update ids in all relevant tables according to the mapping
UPDATE maintainer_repo_metapackages_events
SET metapackage_id = (SELECT new FROM idmap WHERE old = metapackage_id);

ALTER TABLE maintainer_repo_metapackages DISABLE TRIGGER maintainer_repo_metapackage_addremove;
ALTER TABLE maintainer_repo_metapackages DISABLE TRIGGER maintainer_repo_metapackage_update;

UPDATE maintainer_repo_metapackages
SET metapackage_id = (SELECT new FROM idmap WHERE old = metapackage_id);

ALTER TABLE maintainer_repo_metapackages ENABLE TRIGGER maintainer_repo_metapackage_addremove;
ALTER TABLE maintainer_repo_metapackages ENABLE TRIGGER maintainer_repo_metapackage_update;

UPDATE url_relations
SET metapackage_id = (SELECT new FROM idmap WHERE old = metapackage_id);

UPDATE metapackages
SET id = (SELECT new FROM idmap WHERE old = id);

-- Update sequence to generate smaller ids
SELECT setval('metapackages_id_seq', (SELECT max(id) from metapackages));

COMMIT;

-- Cleanup all garbage we've generated
VACUUM FULL maintainer_repo_metapackages_events;
VACUUM FULL maintainer_repo_metapackages;
VACUUM FULL url_relations;
VACUUM FULL metapackages;
