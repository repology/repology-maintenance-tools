\echo Top 10 hosts by total URLs
SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	count(*) AS "Total URLs",
	count(*) FILTER(WHERE priority) AS "Priority URLs"
FROM links
WHERE refcount > 0
GROUP BY "Host"
ORDER BY "Total URLs" DESC
LIMIT 10;

\echo Top 10 hosts by queued URLs
SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	count(*) FILTER (WHERE next_check < now()) AS "Queued URLs",
	count(*) FILTER (WHERE next_check < now() AND priority) AS "Priority URLs"
FROM links
WHERE refcount > 0
GROUP BY "Host"
ORDER BY "Queued URLs" DESC
LIMIT 10;

\echo Top 10 hosts by rate
SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	round(
		(
			count(*) / extract(epoch FROM max(next_check) - now())
		)::numeric,
		3
	) AS "Estimated RPS"
FROM links
WHERE refcount > 0
GROUP BY "Host"
ORDER BY "Estimated RPS" DESC
LIMIT 10;
