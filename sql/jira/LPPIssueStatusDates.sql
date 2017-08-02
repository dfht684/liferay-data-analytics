SELECT 
    jiraissue.ID as 'jiraIssueId',
    CONCAT('LPP-',jiraissue.issuenum) as 'Jira Ticket', 
    if (statuschange.NEWSTRING = 'Audit', statuschange.CREATED, NULL) as 'auditDate',
    if (statuschange.NEWSTRING = 'Automated Testing', statuschange.CREATED, NULL) as 'automatedTestingDate',
    if (statuschange.NEWSTRING = 'Awaiting Help', statuschange.CREATED, NULL) as 'awaitingHelpDate',
    if (statuschange.NEWSTRING = 'Awaiting Product Team', statuschange.CREATED, NULL) as 'awaitingProductTeamDate',
    if (statuschange.NEWSTRING = 'Closed', statuschange.CREATED, NULL) as 'closedDate',
    if (statuschange.NEWSTRING = 'In Progress', statuschange.CREATED, NULL) as 'inProgressDate',
    if (statuschange.NEWSTRING = 'In Review', statuschange.CREATED, NULL) as 'inReviewDate',
    if (statuschange.NEWSTRING = 'On Hold', statuschange.CREATED, NULL) as 'onHoldDate',
    if (statuschange.NEWSTRING = 'Open', statuschange.CREATED, NULL) as 'openDate',
    if (statuschange.NEWSTRING = 'Ready For Investigation', statuschange.CREATED, NULL) as 'readyForInvestigationDate',
    if (statuschange.NEWSTRING = 'Ready For QA', statuschange.CREATED, NULL) as 'readyForQADate',
    if (statuschange.NEWSTRING = 'Reopened', statuschange.CREATED, NULL) as 'reopenedDate',
    if (statuschange.NEWSTRING = 'Resolved', statuschange.CREATED, NULL) as 'resolvedDate',
    if (statuschange.NEWSTRING = 'Solution Proposed', statuschange.CREATED, NULL) as 'solutionProposedDate',
    if (statuschange.NEWSTRING = 'TS Complete', statuschange.CREATED, NULL) as 'tsCompleteDate',
    if (statuschange.NEWSTRING = 'Verified', statuschange.CREATED, NULL) as 'verifiedDate'
FROM jira.jiraissue 
INNER JOIN
	(SELECT 
		changegroup.issueid, 
        changegroup.ID, 
        min(changegroup.CREATED) CREATED, 
        changeitem.OLDVALUE,
        changeitem.OLDSTRING, 
        changeitem.NEWVALUE, 
        changeitem.NEWSTRING
	FROM jira.changegroup
	INNER JOIN jira.changeitem on changegroup.ID = changeitem.groupid
	WHERE changeitem.field='status'
    GROUP BY changegroup.issueid, changeitem.NEWVALUE
	) as statuschange
ON statuschange.issueid = jiraissue.ID
WHERE jiraissue.PROJECT = 11172