SELECT 
    ae.classPK ticketEntryId,
    MAX(IF(ae2.status = 'building-patch', ae2.minDate, NULL)) as firstBuildingPatchDate,
    MAX(IF(ae2.status = 'building-patch', ae2.maxDate, NULL)) as lastBuildingPatchDate,
    MAX(IF(ae2.status = 'closed', ae2.minDate, NULL)) as firstClosedDate,
    MAX(IF(ae2.status = 'closed', ae2.maxDate, NULL)) as lastClosedDate,
    MAX(IF(ae2.status = 'customer-testing', ae2.minDate, NULL)) as firstCustomerTestingDate,
    MAX(IF(ae2.status = 'customer-testing', ae2.maxDate, NULL)) as lastCustomerTestingDate,
    MAX(IF(ae2.status = 'engineer-analyzing', ae2.minDate, NULL)) as firstEngineerAnalyzingDate,
    MAX(IF(ae2.status = 'engineer-analyzing', ae2.maxDate, NULL)) as lastEngineerAnalyzingDate,
    MAX(IF(ae2.status = 'incident-reported', ae2.minDate, NULL)) as firstIncidentReportedDate,
    MAX(IF(ae2.status = 'incident-reported', ae2.maxDate, NULL)) as lastIncidentReportedDate,
    MAX(IF(ae2.status = 'investigating', ae2.minDate, NULL)) as firstInvestigatingDate,
    MAX(IF(ae2.status = 'investigating', ae2.maxDate, NULL)) as lastInvestigatingDate,
    MAX(IF(ae2.status = 'on-hold', ae2.minDate, NULL)) as firstOnHoldDate,
    MAX(IF(ae2.status = 'on-hold', ae2.maxDate, NULL)) as lastOnHoldDate,
    MAX(IF(ae2.status = 'pending', ae2.minDate, NULL)) as firstPendingDate,
    MAX(IF(ae2.status = 'pending', ae2.maxDate, NULL)) as lastPendingDate,
    MAX(IF(ae2.status = 'reopened', ae2.minDate, NULL)) as firstReopenedDate,
    MAX(IF(ae2.status = 'reopened', ae2.maxDate, NULL)) as lastReopenedDate,
    MAX(IF(ae2.status = 'reproduced', ae2.minDate, NULL)) as firstReproducedDate,
    MAX(IF(ae2.status = 'reproduced', ae2.maxDate, NULL)) as lastReproducedDate,
    MAX(IF(ae2.status = 'resolved', ae2.minDate, NULL)) as firstResolvedDate,
    MAX(IF(ae2.status = 'resolved', ae2.maxDate, NULL)) as lastResolvedDate,
    MAX(IF(ae2.status = 'resolved-in-production', ae2.minDate, NULL)) as firstResolvedInProductionDate,
    MAX(IF(ae2.status = 'resolved-in-production', ae2.maxDate, NULL)) as lastResolvedInProductionDate,
    MAX(IF(ae2.status = 'solution-delivered', ae2.minDate, NULL)) as firstSolutionDeliveredDate,
    MAX(IF(ae2.status = 'solution-delivered', ae2.maxDate, NULL)) as lastSolutionDeliveredDate,
    MAX(IF(ae2.status = 'solution-proposed', ae2.minDate, NULL)) as firstSolutionProposedDate,
    MAX(IF(ae2.status = 'solution-proposed', ae2.maxDate, NULL)) as lastSolutionProposedDate
FROM
    OSB_MetricsAuditEntry ae
INNER JOIN (
    SELECT 
         aesub.auditEntryID,
         aesub.classPK,
         aesub.newLabel as status,
         MIN(aesub.createDate) minDate,
         MAX(aesub.createDate) maxDate,
         count(distinct aesub.createDate) statusCount,
         aesub.newValue
    FROM
        OSB_MetricsAuditEntry aesub
    WHERE field='status'
    GROUP BY classPK, newLabel
) ae2 ON
    ae2.classPK = ae.classPK
    AND ae2.newValue = ae.newValue
    AND ae2.minDate = ae.createDate
WHERE 
    field='status'
GROUP BY ae.classPK