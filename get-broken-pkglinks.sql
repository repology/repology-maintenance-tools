WITH hidden AS (
	-- documented failures which cannot be fixed right away
	SELECT NULL AS repo, NULL AS link_type
	UNION ALL SELECT 'dports', 13
	UNION ALL SELECT 'alpine_3_8', 14
	UNION ALL SELECT 'alpine_3_9', 14
	UNION ALL SELECT 'alpine_3_10', 14
	UNION ALL SELECT 'alpine_3_11', 14
	UNION ALL SELECT 'alpine_3_12', 14
	UNION ALL SELECT 'alpine_3_13', 14
	UNION ALL SELECT 'alpine_3_14', 14
	UNION ALL SELECT 'alpine_3_15', 14
	UNION ALL SELECT 'alpine_3_16', 14
	UNION ALL SELECT 'alpine_3_17', 14
	UNION ALL SELECT 'alpine_3_18', 14
	UNION ALL SELECT 'alpine_3_19', 14
	UNION ALL SELECT 'alpine_edge', 14
	UNION ALL SELECT 'opensuse_science_tumbleweed', 9
	UNION ALL SELECT 'opensuse_science_tumbleweed', 5
	UNION ALL SELECT 'opensuse_education_tumbleweed', 9
	UNION ALL SELECT 'opensuse_education_tumbleweed', 5
), package_links AS (
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
		min(url) FILTER (WHERE NOT coalesce(ipv4_success, true)) AS sample
	FROM package_links INNER JOIN links ON (links.id = link_id)
	WHERE
		link_type IN (
			4,  -- PROJECT_HOMEPAGE
			5,  -- PACKAGE_HOMEPAGE
			7,  -- PACKAGE_REPOSITORY
			8,  -- PACKAGE_ISSUE_TRACKER
			9, 10,  -- PACKAGE_RECIPE
			11, 12,  -- PACKAGE_PATCH
			13, 14,  -- PACKAGE_BUILD_LOG
			18,  -- PROJECT_DOWNLOAD
			25,  -- PACKAGE_STATISTICS
			26  -- PACKAGE_BUILD_STATUS
		)
		AND refcount > 0
		AND ipv4_success IS NOT NULL
		AND url NOT LIKE 'http://anonscm.debian.org/%'
		AND url NOT LIKE 'http://alioth.debian.org/%'
	GROUP BY repo, link_type
)
SELECT
	repo,
	link_type,
	round((100.0 * broken / total)::numeric, 2) AS perc_broken,
	broken,
	total,
	sample
FROM repository_stats
WHERE broken / total::float > 0.01 AND NOT EXISTS(SELECT * FROM hidden WHERE hidden.repo = repository_stats.repo AND hidden.link_type = repository_stats.link_type)
ORDER BY perc_broken DESC;
