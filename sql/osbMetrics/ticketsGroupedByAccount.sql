SELECT 
    OSB_MetricsAccountEntry.accountEntryId,
    OSB_MetricsAccountEntry.code_ AS 'accountCode',
    OSB_MetricsAccountEntry.name AS 'accountName',
    OSB_MetricsAccountEntry.createDate AS 'accountCreateDate',
    OSB_MetricsAccountEntry.industry AS 'accountIndustry',
    OSB_MetricsAccountEntry.partnerManagedSupport AS 'partnerManagedSupport',
    OSB_MetricsPartnerEntry.code_ AS 'partnerAccount',
    OSB_MetricsAccountEntry.status AS 'accountStatus',
    OSB_MetricsAccountEntry.tier AS 'accountTier',
    GROUP_CONCAT(DISTINCT OSB_MetricsSupportRegion.name
        ORDER BY OSB_MetricsSupportRegion.name) AS 'supportRegions',
    OSB_MetricsAccountCustomData.ticketCount,
    DATE_SUB(MIN(OSB_MetricsOrderEntry.startDate),
        INTERVAL 1 DAY) AS 'earliestOfferingStartDate',
    DATE_SUB(MAX(OSB_MetricsOfferingEntry.supportEndDate),
        INTERVAL 1 DAY) AS 'latestOfferingSupportEndDate',
    GROUP_CONCAT(DISTINCT OSB_MetricsTicketEntry.envLFR
        ORDER BY OSB_MetricsTicketEntry.envLFR) AS 'liferayVersionsUsed',
    MAX(
            REPLACE(REPLACE(OSB_MetricsTicketEntry.envLFR,'other',0),'N/A',0)
        ) AS 'mostRecentLiferayVersionUsed',
    OSB_MetricsAccountEntry.type_ AS 'accountType',
    IF(OSB_MetricsAccountEntry.redirectAccountEntryId != 0,
        'Yes',
        'No') AS 'renamedAccount',
    ae1.code_ AS 'newAccountCode',
    OSB_MetricsSupportResponse.supportLevel AS 'highestAccountSupportLevel',
    GROUP_CONCAT(DISTINCT OSB_MetricsTicketEntry.component
        ORDER BY OSB_MetricsTicketEntry.component) AS 'ticketComponents',
    GROUP_CONCAT(DISTINCT OSB_MetricsTicketEntry.envAS
        ORDER BY OSB_MetricsTicketEntry.envAS) AS 'applicationServersUsed',
    GROUP_CONCAT(DISTINCT OSB_MetricsTicketEntry.envDB
        ORDER BY OSB_MetricsTicketEntry.envDB) AS 'databasesUsed',
    GROUP_CONCAT(DISTINCT OSB_MetricsTicketEntry.envJVM
        ORDER BY OSB_MetricsTicketEntry.envJVM) AS 'javaVersionsUsed',
    AVG(daysToClose) AS 'averageDaysToClose',
    VARIANCE(daysToClose) AS 'varianceDaysToClose',
    MAX(daysToClose) AS 'maxDaysToCloseForTickets',
    MIN(daysToClose) AS 'minDaysToCloseForTickets',
    IF(OSB_MetricsAccountEntry.code_ LIKE '%trial%',
        1,
        0) AS 'trialAccount',
    GROUP_CONCAT(IF(aw.role = 'advocacy-specialist',
            u.screenName,
            NULL)
        SEPARATOR ', ') AS 'advocacy-specialists',
    GROUP_CONCAT(IF(aw.role = 'experience-manager',
            u.screenName,
            NULL)
        SEPARATOR ', ') AS 'experience-manager',
    GROUP_CONCAT(IF(aw.role = 'managed-services',
            u.screenName,
            NULL)
        SEPARATOR ', ') AS 'managed-services',
    GROUP_CONCAT(IF(aw.role = 'sales',
            u.screenName,
            NULL)
        SEPARATOR ', ') AS 'sales',
    GROUP_CONCAT(IF(aw.role = 'sales-manager',
            u.screenName,
            NULL)
        SEPARATOR ', ') AS 'sales-manager'
FROM
    lportal.OSB_MetricsAccountEntry
LEFT JOIN OSB_MetricsAccountCustomData 
    ON (OSB_MetricsAccountEntry.accountEntryId = OSB_MetricsAccountCustomData.accountEntryId)
LEFT JOIN OSB_MetricsAccountEntries_MetricsSupportRegions 
    ON OSB_MetricsAccountEntry.accountEntryId = OSB_MetricsAccountEntries_MetricsSupportRegions.accountEntryId
LEFT JOIN OSB_MetricsSupportRegion 
    ON OSB_MetricsAccountEntries_MetricsSupportRegions.supportRegionId = OSB_MetricsSupportRegion.supportRegionId
LEFT JOIN OSB_MetricsPartnerEntry 
    ON OSB_MetricsAccountEntry.partnerEntryId = OSB_MetricsPartnerEntry.partnerEntryId
LEFT JOIN OSB_MetricsOfferingEntry 
    ON OSB_MetricsAccountEntry.accountEntryId = OSB_MetricsOfferingEntry.accountEntryId
LEFT JOIN OSB_MetricsOrderEntry 
    ON OSB_MetricsOfferingEntry.orderEntryId = OSB_MetricsOrderEntry.orderEntryId
LEFT JOIN OSB_MetricsAccountEntry 
    ae1 ON OSB_MetricsAccountEntry.redirectAccountEntryId = ae1.accountEntryId
LEFT JOIN OSB_MetricsTicketEntry 
    ON OSB_MetricsAccountEntry.accountEntryId = OSB_MetricsTicketEntry.accountEntryId
LEFT JOIN OSB_MetricsTicketCustomData 
    ON OSB_MetricsTicketEntry.ticketEntryId = OSB_MetricsTicketCustomData.ticketEntryId
LEFT JOIN OSB_MetricsSupportResponse 
    ON OSB_MetricsAccountEntry.highestSupportResponseId = OSB_MetricsSupportResponse.supportResponseId
LEFT JOIN OSB_MetricsAccountWorker 
    aw ON OSB_MetricsAccountEntry.accountEntryId = aw.accountEntryId
LEFT JOIN OSB_MetricsUser 
    u ON u.userId = aw.userId
GROUP BY OSB_MetricsAccountEntry.accountEntryId
ORDER BY OSB_MetricsAccountEntry.code_