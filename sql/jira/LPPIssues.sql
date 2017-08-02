#normalizing the jira database tables , specifically the LPP project for reporting needs

SELECT 
    issuesummary.*,
    fixVersions.versions AS 'fixVersions',
    issueVersions.versions AS 'issueVersions',
    supportOffice.SupportOffice,
    lesaTicketRef.LESA_TicketReference,
    SUBSTRING_INDEX(lesaTicketRef.LESA_TicketReference, '-', 1) AS 'LESA_accountCodeReference',
	issueFixedIn.issueFixedIn,
    IFNULL(issuesReopenedSubQuery.countReopened,0)

FROM
    (SELECT 
        project_key.PROJECT_KEY,
            jiraissue.project,
            jiraissue.ID AS 'jiraIssueId',
            jiraissue.issuenum,
            issuetype.pname AS 'issueType',
            issuestatus.pname AS 'issueStatus',
            GROUP_CONCAT(DISTINCT (component.cname)) AS 'components',
            jiraissue.summary,
            jiraissue.description,
            jiraissue.creator,
            jiraissue.assignee,
            jiraissue.reporter,
            jiraissue.created,
            jiraissue.updated,
            jiraissue.duedate,
            jiraissue.resolutiondate,
            jiraissue.votes,
            jiraissue.watches,
            priority.pname AS 'priority',
            resolution.pname AS 'resolution'
    FROM
        jira.jiraissue
    INNER JOIN jira.project_key ON jiraissue.PROJECT = project_key.PROJECT_ID
    INNER JOIN jira.issuetype ON jiraissue.issueType = issuetype.ID
    INNER JOIN jira.issuestatus ON issuestatus.ID = jiraissue.issuestatus
    LEFT JOIN jira.nodeassociation na ON jiraissue.ID = na.source_node_id
    LEFT JOIN jira.component ON na.SINK_NODE_ID = component.id
    LEFT JOIN jira.projectversion ON na.SINK_NODE_ID = projectversion.id
    LEFT JOIN jira.resolution ON resolution.id=jiraissue.resolution
    LEFT JOIN jira.priority ON priority.id=jiraissue.priority
    WHERE
        project_key.project_key = 'LPP'
        and jiraissue.created>='2013-01-01%'
            AND na.ASSOCIATION_TYPE = 'IssueComponent'
    GROUP BY jiraissue.issuenum
    ORDER BY jiraissue.issuenum DESC) AS issuesummary

LEFT JOIN
    (SELECT 
        jiraissue.issuenum,
            GROUP_CONCAT(projectversion.vname) AS 'versions'
    FROM
        jira.jiraissue
    INNER JOIN jira.project_key ON jiraissue.PROJECT = project_key.PROJECT_ID
    INNER JOIN jira.issuetype ON jiraissue.issueType = issuetype.ID
    INNER JOIN jira.issuestatus ON issuestatus.ID = jiraissue.issuestatus
    LEFT JOIN jira.nodeassociation na ON jiraissue.ID = na.source_node_id
    LEFT JOIN jira.component ON na.SINK_NODE_ID = component.id
    LEFT JOIN jira.projectversion ON na.SINK_NODE_ID = projectversion.id
    WHERE
        project_key.project_key = 'LPP'
            AND na.ASSOCIATION_TYPE = 'IssueFixVersion'
    GROUP BY jiraissue.issuenum
    ORDER BY jiraissue.issuenum DESC) AS fixVersions ON issuesummary.issuenum = fixVersions.issuenum
        LEFT JOIN
    (SELECT 
        jiraissue.issuenum,
            GROUP_CONCAT(projectversion.vname) AS 'versions'
    FROM
        jira.jiraissue
    INNER JOIN jira.project_key ON jiraissue.PROJECT = project_key.PROJECT_ID
    INNER JOIN jira.issuetype ON jiraissue.issueType = issuetype.ID
    INNER JOIN jira.issuestatus ON issuestatus.ID = jiraissue.issuestatus
    LEFT JOIN jira.nodeassociation na ON jiraissue.ID = na.source_node_id
    LEFT JOIN jira.component ON na.SINK_NODE_ID = component.id
    LEFT JOIN jira.projectversion ON na.SINK_NODE_ID = projectversion.id
    WHERE
        project_key.project_key = 'LPP'
            AND na.ASSOCIATION_TYPE = 'IssueVersion'
    GROUP BY jiraissue.issuenum
    ORDER BY jiraissue.issuenum DESC) AS issueVersions ON issuesummary.issuenum = issueVersions.issuenum
        LEFT JOIN
    (SELECT 
        jiraissue.issuenum,
            IF(customfield.cfname = 'Support Office', customfieldoption.customvalue, 'No Support Office') AS 'SupportOffice'
    FROM
        jira.jiraissue
    INNER JOIN jira.customfieldvalue ON jiraissue.id = customfieldvalue.issue
    INNER JOIN jira.customfield ON customfieldvalue.customfield = customfield.ID
    LEFT JOIN customfieldoption ON customfieldvalue.stringvalue = customfieldoption.id
    WHERE
        jiraissue.project = 11172
            AND cfname IN ('Support Office') 
	) AS supportOffice ON issuesummary.issuenum = supportOffice.issuenum

LEFT JOIN
(
    SELECT 
        jiraissue.issuenum,
            IF(customfield.cfname = 'LESA Permalink', 
                SUBSTRING_INDEX(customfieldvalue.stringvalue, '/', -1), 'No Ticket') AS 'LESA_TicketReference'
    FROM
        jira.jiraissue
    INNER JOIN jira.customfieldvalue ON jiraissue.id = customfieldvalue.issue
    INNER JOIN jira.customfield ON customfieldvalue.customfield = customfield.ID
    LEFT JOIN customfieldoption ON customfieldvalue.stringvalue = customfieldoption.id
    WHERE
        jiraissue.project = 11172
        and
        cfname IN ('LESA Permalink')
) AS lesaTicketRef
    ON lesaTicketRef.issuenum=issuesummary.issuenum

LEFT JOIN
(
    SELECT 
        jiraissue.issuenum,
            IF(customfield.cfname = 'Issue Fixed In', 
               customfieldoption.customvalue, 'N/A') AS 'issueFixedIn'
    FROM
        jira.jiraissue
    INNER JOIN jira.customfieldvalue ON jiraissue.id = customfieldvalue.issue
    INNER JOIN jira.customfield ON customfieldvalue.customfield = customfield.ID
    LEFT JOIN customfieldoption ON customfieldvalue.stringvalue = customfieldoption.id
    WHERE
        jiraissue.project = 11172
        and
        cfname IN ('Issue Fixed In')
) AS issueFixedIn
    ON issueFixedIn.issuenum=issuesummary.issuenum

LEFT JOIN 
    (SELECT 
        jiraissue.ID AS 'jiraIssueId',
        COUNT(jiraissue.ID) AS 'countReopened'
    FROM jira.changegroup
        LEFT JOIN jira.changeitem ON changegroup.ID = changeitem.groupid
        INNER JOIN jira.jiraissue ON changegroup.issueid = jiraissue.ID
    WHERE changeitem.NEWVALUE = 4
        AND changeitem.field = 'status'
        AND jiraissue.PROJECT = 11172
    GROUP BY changegroup.issueid
) AS issuesReopenedSubQuery
    ON issuesReopenedSubQuery.jiraIssueId = issuesummary.jiraIssueId
GROUP BY issuesummary.jiraIssueId


