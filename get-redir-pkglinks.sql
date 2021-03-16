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
		count(*) FILTER (WHERE ipv4_permanent_redirect_target is not null) AS redirects,
		count(*) AS total,
		min(url) FILTER (WHERE ipv4_permanent_redirect_target is not null) AS sample
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
	round((100.0 * redirects / total)::numeric, 2) AS perc_redir,
	redirects,
	total,
	sample
FROM
	repository_stats
WHERE redirects / total::float > 0.01
ORDER BY perc_redir DESC;
