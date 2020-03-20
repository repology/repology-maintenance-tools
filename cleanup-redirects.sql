-- manual redirects which duplicate auto redirects
WITH auto_redirects AS (
	SELECT DISTINCT
        (SELECT effname FROM metapackages WHERE id = old.project_id) AS oldname,
        (SELECT effname FROM metapackages WHERE id = new.project_id) AS newname
    FROM project_redirects AS old INNER JOIN project_redirects AS new USING(repository_id, trackname)
    WHERE
        NOT old.is_actual AND new.is_actual
)
DELETE
FROM project_redirects_manual
WHERE EXISTS (
	SELECT *
	FROM auto_redirects
	WHERE
		auto_redirects.oldname = project_redirects_manual.oldname AND
		auto_redirects.newname = project_redirects_manual.newname
	)
;

-- projects that never existed
DELETE
FROM project_redirects_manual
WHERE NOT EXISTS (
	SELECT *
	FROM metapackages
	WHERE
		metapackages.effname = project_redirects_manual.newname AND metapackages.num_repos > 0
	)
;

-- half-redirects are useless
DELETE
FROM project_redirects
WHERE project_id IN(
	SELECT
		project_id
	FROM project_redirects
	GROUP BY project_id
	HAVING count(*) = 1
);
