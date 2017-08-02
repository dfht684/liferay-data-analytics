SELECT
	Organization_.name AS Organization,
	CASE LoopDivision.type_
		WHEN -1 THEN 'removed'
		WHEN 1 THEN 'root'
		WHEN 2 THEN 'department'
		WHEN 3 THEN 'team'
		WHEN 4 THEN 'location'
		ELSE NULL
	END as OrgType,
	COUNT(DISTINCT Users_Orgs.userId) AS CountOrganizationMembers,
	GROUP_CONCAT(User_.emailAddress)
FROM
	Organization_
LEFT JOIN 
	Users_Orgs ON
		Users_Orgs.organizationId = Organization_.organizationId
LEFT JOIN
	User_ ON
		User_.userId = Users_Orgs.userId
INNER JOIN	
	LoopDivision ON
		LoopDivision.organizationId = Organization_.organizationId
GROUP BY 
	Organization_.name	