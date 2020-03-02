TRUNCATE TABLE project_redirects2;

WITH candidates AS (
	SELECT DISTINCT
		effname,
		projectname_seed,
		trackname,
		repo
	FROM packages
	WHERE
		effname != projectname_seed
		AND repo NOT IN (SELECT name FROM repositories WHERE "type" = 'modules')
		AND EXISTS (SELECT * FROM metapackages WHERE metapackages.effname = projectname_seed AND metapackages.num_repos_nonshadow = 0)
), prepared AS (
	SELECT
		(SELECT id FROM metapackages WHERE metapackages.effname = candidates.effname) AS actual_project_id,
		(SELECT id FROM metapackages WHERE metapackages.effname = candidates.projectname_seed) AS old_project_id,
		(SELECT id FROM repositories WHERE repositories.name = candidates.repo) AS repository_id,
		trackname
	FROM candidates
)
INSERT INTO project_redirects2 (
	project_id,
	repository_id,
	is_actual,
	trackname
)
SELECT DISTINCT
	actual_project_id,
	repository_id,
	true,
	trackname
FROM prepared
UNION ALL
SELECT DISTINCT
	old_project_id,
	repository_id,
	false,
	trackname
FROM prepared;
