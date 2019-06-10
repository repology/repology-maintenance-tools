-- Get projects for which the latest version was flagged as an `incorrect',
-- but uningnored by a package without such flag.

-- It's either than a fake version was officially released, or a repository
-- was added which needs to be added to ignore list

-- XXX: add UNTRUSTED flag here when it's fixed to be less ambiguous (see #861)

SELECT
	effname,
	count(DISTINCT family) AS spread,
	count(DISTINCT family) FILTER (WHERE versionclass = 1) AS newest,
	count(DISTINCT family) FILTER (WHERE versionclass = 1 AND (flags & 8)::boolean) AS newest_incorrect,
	array_agg(DISTINCT family) FILTER (WHERE versionclass = 1 AND (flags & 8)::boolean) AS families_incorrect,
	array_agg(DISTINCT family) FILTER (WHERE versionclass = 1 AND NOT (flags & 8)::boolean) AS families_allowed
FROM packages
GROUP BY effname
HAVING
	count(DISTINCT family) FILTER (WHERE versionclass = 1 AND (flags & 8)::boolean) >= 1
ORDER BY newest_incorrect DESC, spread DESC, effname;
