WITH package_links AS (
	SELECT
		repo,
		(json_array_elements(links)->>0)::integer AS link_type,
		(json_array_elements(links)->>1)::integer AS link_id
	FROM packages
), repository_stats AS (
	SELECT
		repo,
		link_type,
		count(*) FILTER (WHERE NOT coalesce(ipv4_success, true)) AS broken,
		count(*) AS total,
		min(url) FILTER (WHERE NOT coalesce(ipv4_success, true)) AS url_sample
	FROM package_links INNER JOIN links ON (links.id = link_id)
	WHERE link_type IN (
		4,  -- PACKAGE_HOMEPAGE
		7,  -- PACKAGE_REPOSITORY
		9, 10,  -- PACKAGE_RECIPE
		11, 12,  -- PACKAGE_PATCH
		13, 14,  -- PACKAGE_BUILD_LOG
		24  --PACKAGE_REPOSITORY_DIR
	) AND ipv4_success IS NOT NULL
	GROUP BY repo, link_type
)
SELECT
	repo,
	link_type,
	round((100.0 * broken / total)::numeric, 2) AS perc_broken,
	broken,
	total,
	url_sample
FROM
	repository_stats
WHERE broken > 0
ORDER BY perc_broken DESC;
