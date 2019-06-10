-- List projects which are newest only in Windows repos
-- This may mean that projects have different versioning scheme in
-- Windows and should be added to 902 ruleset

WITH windows_repos AS (
	SELECT * FROM (VALUES
		('chocolatey'),
		('cygwin'),
		('just-install'),
		('msys2_mingw'),
		('msys2_msys2'),
		('npackd'),
		('reactos'),
		('scoop'),
		('vcpkg'),
		('yacp')
	) AS windows_repos(repo))
SELECT DISTINCT
	effname
FROM packages
GROUP BY effname
HAVING
	count(*) FILTER (WHERE repo IN (SELECT repo FROM windows_repos) AND versionclass = 1) > 0  -- has newest windows versions
	AND
	count(*) FILTER (WHERE repo NOT IN (SELECT repo FROM windows_repos) AND versionclass = 1) = 0  -- has no newest non-windows versions
	AND
	count(*) FILTER (WHERE repo NOT IN (SELECT repo FROM windows_repos)) > 0  -- has non-windows versions
ORDER BY effname;
