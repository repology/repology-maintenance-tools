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

TRUNCATE TABLE project_names;

INSERT INTO project_names (
    project_id,
    repository_id,
    name_type,
    name
)
SELECT
    (SELECT id FROM metapackages WHERE metapackages.effname = tmp.effname) AS project_id,
    (SELECT id FROM repositories WHERE repositories.name = tmp.repo) AS repository_id,
    name_type,
    name
FROM (
    SELECT effname, repo, 'name'::project_name_type AS name_type, name FROM packages WHERE name IS NOT NULL
    UNION
    SELECT effname, repo, 'srcname'::project_name_type AS name_type, srcname FROM packages WHERE srcname IS NOT NULL
    UNION
    SELECT effname, repo, 'binname'::project_name_type AS name_type, binname FROM packages WHERE binname IS NOT NULL
) AS tmp;
