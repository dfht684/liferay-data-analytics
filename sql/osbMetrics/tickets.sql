SELECT 
    OSB_MetricsTicketEntry.ticketEntryId,
    OSB_MetricsSupportRegion.name AS 'supportRegion',
    OSB_MetricsAccountEntry.code_ AS 'accountCode',
    OSB_MetricsTicketEntry.modifiedDate,
    OSB_MetricsTicketEntry.component,
    OSB_MetricsTicketEntry.username AS 'ticketCreator',
    primaryAssignee.screenname AS 'primaryAssignee',
    OSB_MetricsTicketEntry.createDate AS 'ticketCreateDate',
    OSB_MetricsTicketEntry.closedDate AS 'ticketClosedDate',
    OSB_MetricsTicketEntry.severity,
    OSB_MetricsTicketEntry.status,
    OSB_MetricsTicketEntry.escalationLevel,
    OSB_MetricsTicketEntry.subject,
    OSB_MetricsTicketEntry.resolution,
    OSB_MetricsTicketEntry.description,
    OSB_MetricsTicketEntry.envAS,
    OSB_MetricsTicketEntry.envBrowser,
    OSB_MetricsTicketEntry.envBrowserCustom,
    OSB_MetricsTicketEntry.envDB,
    OSB_MetricsTicketEntry.envJVM,
    OSB_MetricsTicketEntry.dueDate,
    IF(OSB_MetricsTicketEntry.envLFR LIKE '%7.0%',
        7.0,
        OSB_MetricsTicketEntry.envLFR) AS 'envLFR',
    OSB_MetricsTicketEntry.envName,
    OSB_MetricsTicketEntry.envOS,
    OSB_MetricsTicketEntry.envOSCustom,
    OSB_MetricsTicketEntry.subcomponent,
    OSB_MetricsTicketEntry.subcomponentCustom,
    timeMetrics.pendingCustomerTime,
    timeMetrics.pendingPartnerTime,
    timeMetrics.pendingLiferayTime,
    ticketCustomData.timesReopened,
    timeMetrics.averageLiferayResponseTime,
    ticketCustomData.commentCount,
    timeMetrics.buildingPatchTime,
    timeMetrics.engineerAnalyzingTime,
    timeMetrics.incidentReportedTime,
    timeMetrics.investigatingTime,
    timeMetrics.onHoldTime,
    timeMetrics.pendingWorkerTime,
    timeMetrics.reopenedTime,
    timeMetrics.reproducedTime,
    timeMetrics.resolvedInProductionTime,
    timeMetrics.solutionDeliveredTime,
    timeMetrics.solutionProposedTime,
    ticketCustomData.critical,
    timeMetrics.timeToFirstLiferayComment,
    timeMetrics.timeToFirstPartnerComment,
    timeMetrics.averageCustomerResponseTime,
    timeMetrics.averagePartnerResponseTime,
    IF(OSB_MetricsTicketEntry.closedDate IS NOT NULL,
        timeMetrics.daysToClose,
        NULL) AS 'daysToResolve',
    DATEDIFF(OSB_MetricsTicketEntry.closedDate,
            OSB_MetricsTicketEntry.createDate) AS 'daysToClose',
    ticketCustomData.primaryTicketWorkerUserId,
    COUNT(DISTINCT (OSB_MetricsTicketFeedback.ticketFeedbackId)) AS 'numberOfFeedbackReceived',
    COUNT(DISTINCT (OSB_MetricsTicketSolution.ticketSolutionId)) AS 'numberOfSolutionsProvided',
    (((timeMetrics.daysToClose * 86400) - timeMetrics.onHoldTime) / 86400) AS 'daysToResolveMinusOnHoldTime',
    COUNT(DISTINCT (ticketAttachmentId)) AS 'numberOfAttachments',
    GROUP_CONCAT(DISTINCT (OSB_MetricsTicketAttachment.fileName)
        ORDER BY OSB_MetricsTicketAttachment.filename) AS 'allAttachments',
    GROUP_CONCAT(IF(OSB_MetricsTicketAttachment.fileName LIKE '%liferay-hotfix%',
            OSB_MetricsTicketAttachment.fileName,
            NULL)
        SEPARATOR ', ') AS 'fixAttachments',
    IF(GROUP_CONCAT(OSB_MetricsTicketAttachment.fileName
            ORDER BY OSB_MetricsTicketAttachment.filename) LIKE '%liferay-hotfix%',
        1,
        0) AS 'fixProvided',
    TIMESTAMPDIFF(MONTH,
        OSB_MetricsAccountEntry.createDate,
        OSB_MetricsTicketEntry.createDate) AS 'numberOfMonthsFromAccountCreateDate',
    IF(GROUP_CONCAT(OSB_MetricsTicketLink.url
            ORDER BY OSB_MetricsTicketLink.url) LIKE '%LPP-%',
        1,
        0) AS 'lppLinked',
    GROUP_CONCAT(DISTINCT (IF(OSB_MetricsTicketLink.url LIKE '%LPP-%',
            OSB_MetricsTicketLink.url,
            NULL))
        SEPARATOR ', ') AS 'listOfLppsLinked',
    CONCAT(OSB_MetricsAccountEntry.code_,
            '-',
            OSB_MetricsTicketEntry.ticketId) AS 'ticketNumber',
    IF(ticketCustomData.timesReopened > 0,
        'Yes',
        'No') AS 'reOpened',
    DATEDIFF(OSB_MetricsTicketEntry.dueDate,
            OSB_MetricsTicketEntry.closedDate) AS 'daysBeforeDueDate',
    GROUP_CONCAT(DISTINCT (helpers.emailAddress)
        ORDER BY helpers.emailAddress ASC) AS 'helperAssignees',
    COUNT(DISTINCT (helpers.emailAddress)) AS 'numberOfHelperAssignees'
FROM
    OSB_MetricsTicketEntry
        LEFT JOIN
    OSB_MetricsAccountEntry ON OSB_MetricsAccountEntry.accountEntryId = OSB_MetricsTicketEntry.accountEntryId
        LEFT JOIN
    OSB_MetricsTicketCustomData timeMetrics ON OSB_MetricsTicketEntry.ticketEntryId = timeMetrics.ticketEntryId
        AND OSB_MetricsTicketEntry.createDate > '2015-12-19'
        AND OSB_MetricsTicketEntry.closedDate IS NOT NULL
        LEFT JOIN
    OSB_MetricsTicketCustomData ticketCustomData ON OSB_MetricsTicketEntry.ticketEntryId = ticketCustomData.ticketEntryId
        LEFT JOIN
    OSB_MetricsSupportRegion ON (OSB_MetricsSupportRegion.supportRegionId = OSB_MetricsTicketEntry.supportRegionId)
        LEFT JOIN
    OSB_MetricsTicketAttachment ON OSB_MetricsTicketAttachment.ticketEntryId = OSB_MetricsTicketEntry.ticketEntryId
        LEFT JOIN
    OSB_MetricsTicketFeedback ON (OSB_MetricsTicketFeedback.ticketEntryId = OSB_MetricsTicketEntry.ticketEntryId)
        LEFT JOIN
    OSB_MetricsTicketSolution ON (OSB_MetricsTicketEntry.ticketEntryid = OSB_MetricsTicketSolution.ticketEntryId)
        LEFT JOIN
    OSB_MetricsUser primaryAssignee ON (primaryAssignee.userId = ticketCustomData.primaryTicketWorkerUserId)
        LEFT JOIN
    OSB_MetricsTicketLink ON OSB_MetricsTicketLink.ticketEntryId = OSB_MetricsTicketEntry.ticketEntryId
        LEFT JOIN
    OSB_MetricsTicketWorker tw ON OSB_MetricsTicketEntry.ticketEntryid = tw.ticketEntryid
        AND tw.primary_ = 0
        LEFT JOIN
    OSB_MetricsUser helpers ON tw.userId = helpers.userId
GROUP BY OSB_MetricsTicketEntry.ticketEntryId
ORDER BY OSB_MetricsTicketEntry.ticketEntryId DESC