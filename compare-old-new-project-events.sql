SELECT
	effname,
	b.type,
	b.data
FROM metapackages_events a
FULL OUTER JOIN metapackages_events2 b USING(effname, ts, type, data)
WHERE a.effname IS NULL OR b.effname IS NULL
ORDER BY effname, ts;
