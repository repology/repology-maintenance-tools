SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	count(*) AS "Total URLs",
	count(*) FILTER(WHERE priority) AS "Priority URLs"
FROM links
WHERE refcount > 0
GROUP BY "Host"
ORDER BY "Total URLs" DESC
LIMIT 10;

SELECT
	substring(url from '.*://([^/]*)') AS "Host",
	count(*) FILTER (WHERE next_check < now()) AS "Overdue total",
	count(*) FILTER (WHERE next_check < now() AND last_checked IS NULL) AS "Overdue new URLs",
	count(*) FILTER (WHERE next_check < now() AND last_checked IS NULL AND priority) AS "Overdue priority new URLs",
	count(*) FILTER (WHERE next_check < now() AND last_checked IS NOT NULL) AS "Overdue URL updates",
	count(*) FILTER (WHERE next_check < now() AND last_checked IS NOT NULL AND priority) AS "Overdue priority URL updates"
FROM links
WHERE refcount > 0
GROUP BY "Host"
HAVING count(*) FILTER (WHERE next_check < now()) > 100
ORDER BY count(*) FILTER (WHERE next_check < now()) DESC
LIMIT 15;

SELECT
	host AS "Host",
	round((regular + priority)::numeric, 3) AS "Total RPS",
	round(regular::numeric, 3) AS "Regular RPS",
	round(priority::numeric, 3) AS "Priority RPS"
FROM (
	SELECT
		substring(url from '.*://([^/]*)') AS host,
		coalesce(
			count(*) FILTER (WHERE NOT priority) /
				extract(epoch FROM max(next_check) FILTER (WHERE NOT priority) - now()),
			0
		) AS regular,
		coalesce(
			count(*) FILTER (WHERE priority) /
				extract(epoch FROM max(next_check) FILTER (WHERE priority) - now()),
			0
		) AS priority
	FROM links
	WHERE refcount > 0
	GROUP BY host
	HAVING count(*) > 10000
) AS tmp
ORDER BY "Total RPS" DESC NULLS LAST
LIMIT 10;
