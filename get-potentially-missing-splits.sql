with package_links as  (
	select
		effname,
		(json_array_elements(links)->>0)::integer as link_type,
		(json_array_elements(links)->>1)::integer as link_id
	from packages
	where effname like '%-unclassified'
)
select distinct
	effname,
	url
from package_links
inner join links on links.id = package_links.link_id
where link_type = 0
and (
	(ipv6_success and ipv6_permanent_redirect_target is null)
	or (ipv4_success and ipv4_permanent_redirect_target is null)
)
and not (
	url like '%debian.org/%'  -- not considered as valid upstream
)
order by effname;
