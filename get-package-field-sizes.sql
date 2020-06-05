SELECT key, value::integer
FROM json_each_text((
	SELECT
		json_build_object(
			'id', sum(pg_column_size(id)),

			'repo', sum(pg_column_size(repo)),
			'family', sum(pg_column_size(family)),
			'subrepo', sum(pg_column_size(subrepo)),

			'name', sum(pg_column_size(name)),
			'srcname', sum(pg_column_size(srcname)),
			'binname', sum(pg_column_size(binname)),
			'binnames', sum(pg_column_size(binnames)),
			'trackname', sum(pg_column_size(trackname)),
			'visiblename', sum(pg_column_size(visiblename)),
			'projectname_seed', sum(pg_column_size(projectname_seed)),

			'origversion', sum(pg_column_size(origversion)),
			'rawversion', sum(pg_column_size(rawversion)),

			'arch', sum(pg_column_size(arch)),

			'maintainers', sum(pg_column_size(maintainers)),
			'category', sum(pg_column_size(category)),
			'comment', sum(pg_column_size(comment)),
			'homepage', sum(pg_column_size(homepage)),
			'licenses', sum(pg_column_size(licenses)),
			'downloads', sum(pg_column_size(downloads)),

			'extrafields', sum(pg_column_size(extrafields)),

			'cpe_vendor', sum(pg_column_size(cpe_vendor)),
			'cpe_product', sum(pg_column_size(cpe_product)),
			'cpe_edition', sum(pg_column_size(cpe_edition)),
			'cpe_lang', sum(pg_column_size(cpe_lang)),
			'cpe_sw_edition', sum(pg_column_size(cpe_sw_edition)),
			'cpe_target_sw', sum(pg_column_size(cpe_target_sw)),
			'cpe_target_hw', sum(pg_column_size(cpe_target_hw)),
			'cpe_other', sum(pg_column_size(cpe_other)),

			'effname', sum(pg_column_size(effname)),
			'version', sum(pg_column_size(version)),
			'versionclass', sum(pg_column_size(versionclass)),

			'flags', sum(pg_column_size(flags)),
			'shadow', sum(pg_column_size(shadow)),

			'flavors', sum(pg_column_size(flavors)),
			'branch', sum(pg_column_size(branch))
		) AS data
	FROM packages
))
ORDER BY value NULLS FIRST;
