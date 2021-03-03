\echo Top 10 hosts by URL count
SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	count(*) AS "Total URLs",
	count(*) FILTER (WHERE next_check < now()) AS "Queued URLs"
FROM links
WHERE refcount > 0
GROUP BY "Host"
ORDER BY "Total URLs" DESC
LIMIT 10;

\echo Top 10 hosts by rate
SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	round(
		count(*) / avg(
			CASE WHEN next_check > now()
				THEN extract(epoch FROM next_check - now())
				ELSE 0
			END
		)::numeric,
		3
	) AS "Estimated RPS"
FROM links
WHERE refcount > 0
GROUP BY "Host"
HAVING count(*) > 1000
ORDER BY "Estimated RPS" DESC
LIMIT 10;
