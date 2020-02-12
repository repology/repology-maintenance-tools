SELECT
	CASE WHEN a.type IS NULL then '+' ELSE '-' END AS x,
	(select maintainer from maintainers where id = maintainer_id) AS maintainer,
	(select name from repositories where id = repository_id) AS repo,
	(select effname from metapackages where id = metapackage_id) AS effname,
	type,
	ts,
	data
FROM maintainer_repo_metapackages_events a
FULL OUTER JOIN maintainer_repo_metapackages_events2 b USING(maintainer_id, repository_id, metapackage_id, type, ts, data)
WHERE a.type IS NULL OR b.type IS NULL
ORDER BY maintainer, repo, effname;
