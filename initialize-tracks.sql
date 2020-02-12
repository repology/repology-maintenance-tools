-- Copyright (C) 2020 Dmitry Marakasov <amdmi3@amdmi3.ru>
--
-- This file is part of repology
--
-- repology is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- repology is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with repology.  If not, see <http://www.gnu.org/licenses/>.

TRUNCATE TABLE repo_tracks;

INSERT INTO repo_tracks (
    repository_id,
    trackname,
    refcount
)
SELECT
	(SELECT id FROM repositories WHERE repositories.name = repo) AS repository_id,
	trackname,
	count(*) AS refcount
FROM packages
GROUP BY repo, trackname;

VACUUM FULL repo_tracks;

TRUNCATE TABLE repo_track_versions;

INSERT INTO repo_track_versions (
	repository_id,
	trackname,
	version,
	refcount,
	any_statuses,
	any_flags
)
SELECT
	(SELECT id FROM repositories WHERE repositories.name = repo) AS repository_id,
	trackname,
	version,
	count(*) AS refcount,
	bit_or(1 << versionclass) AS any_statuses,
	bit_or(flags) AS any_flags
FROM packages
GROUP BY repo, trackname, version;

VACUUM FULL repo_track_versions;

TRUNCATE TABLE project_releases;

WITH tracknames AS (
    SELECT DISTINCT
        effname,
        (SELECT id FROM repositories WHERE name=packages.repo) AS repository_id,
        trackname
    FROM packages
)
INSERT INTO project_releases (
    effname,
    version,
    start_ts,
    trusted_start_ts,
    end_ts
)
SELECT
    effname,
    version,
    min(start_ts),
    min(start_ts) FILTER (WHERE NOT is_ignored_by_masks(any_statuses, any_flags)),
    max(end_ts)
FROM tracknames INNER JOIN repo_track_versions USING(repository_id, trackname)
GROUP BY effname, version;

VACUUM FULL project_releases;
