SELECT 
    contactUser.emailAddress AS 'ProjectContactEmail',
    OSB_MetricsAccountEntry.countryId,
    GROUP_CONCAT(DISTINCT contactCountry.osbCountry) AS 'ProjectContactCountry',
    GROUP_CONCAT(DISTINCT projectAddressCountry.name) AS 'ProjectAddressCountry',
    GROUP_CONCAT(DISTINCT projectCountry.name) AS 'ProjectCountry',
    COALESCE(contactCountry.osbCountry,projectAddressCountry.name,projectCountry.name) AS 'CalculatedCountry',
    accountContact.role AS 'ProjectContactRole',
    DATE_FORMAT(MAX(offeringDate), '%Y-%m-%d') AS 'LastOfferingDate',
    DATE_FORMAT(GROUP_CONCAT(DISTINCT OSB_MetricsOfferingEntry.createDate), '%Y-%m-%d') AS 'AllOfferingDates',
    COALESCE(redirectedAccountEntry.code_, OSB_MetricsAccountEntry.code_) AS 'ProjectCode',
    COALESCE(redirectedAccountEntry.name, OSB_MetricsAccountEntry.name) AS 'ProjectName',
    COALESCE(redirectedAccountEntry.tier, OSB_MetricsAccountEntry.tier) AS 'ProjectTier',
    
    CONCAT('https://web.liferay.com/group/customer/support/-/support/ticket/', 
        COALESCE(redirectedAccountEntry.code_, OSB_MetricsAccountEntry.code_)
    ) AS 'ProjectURL',

    COALESCE(
        redirectedAccountEntry.type_, OSB_MetricsAccountEntry.type_
    ) AS 'ProjectType',
    
    IF(OSB_MetricsAccountEntry.code_ LIKE '%trial%',
        'Yes',
        'No'
    ) AS 'IsTrialProject',
    GROUP_CONCAT(OSB_MetricsOfferingEntry.type_) AS 'OfferingType',
    GROUP_CONCAT(product.name) AS 'products',
    GROUP_CONCAT(OSB_MetricsOfferingEntry.status) AS 'productsStatus'

FROM
    OSB_MetricsAccountEntry
INNER JOIN OSB_MetricsOfferingEntry
    ON OSB_MetricsAccountEntry.accountEntryId = OSB_MetricsOfferingEntry.accountEntryId
INNER JOIN 
    (SELECT
        offeringEntryId,
        OSB_MetricsOfferingEntry.createDate AS offeringDate
    FROM 
        OSB_MetricsOfferingEntry
    INNER JOIN  
        OSB_MetricsProductEntry 
        ON OSB_MetricsProductEntry.productEntryId = OSB_MetricsOfferingEntry.productEntryId
        AND OSB_MetricsProductEntry.name like '%Digital Enterprise%'
    ) AS OfferingSubQuery
    ON OfferingSubQuery.offeringEntryId = OSB_MetricsOfferingEntry.offeringEntryId
INNER JOIN OSB_MetricsProductEntry product
    ON OSB_MetricsOfferingEntry.productEntryId = product.productEntryId
LEFT JOIN 
    OSB_MetricsAddress address
    ON address.classPK = OSB_MetricsAccountEntry.accountEntryId
LEFT JOIN 
    OSB_MetricsCountry projectAddressCountry
    ON projectAddressCountry.countryId = address.countryId
LEFT JOIN OSB_MetricsAccountEntry redirectedAccountEntry
    ON OSB_MetricsAccountEntry.redirectAccountEntryId = redirectedAccountEntry.accountEntryId
LEFT JOIN OSB_MetricsCountry projectCountry
    ON OSB_MetricsAccountEntry.countryId = projectCountry.countryId
LEFT JOIN OSB_MetricsAccountCustomer
    accountContact ON OSB_MetricsAccountEntry.accountEntryId = accountContact.accountEntryId
LEFT JOIN OSB_MetricsUser 
    contactUser ON contactUser.userId = accountContact.userId
LEFT JOIN OSB_MetricsUserCustomData
    contactCountry ON contactCountry.userId = accountContact.userId
WHERE
    OSB_MetricsAccountEntry.status = 'approved'
#    AND OSB_MetricsAccountEntry.code_ = 'AAAMICHIGAN'
#   AND contactCountry.osbCountry IS NULL
#   AND projectCountry.name IS NULL
#   AND contactCountry.osbCountry != projectCountry.name
GROUP BY OSB_MetricsAccountEntry.accountEntryId, accountContact.userId
ORDER BY OSB_MetricsAccountEntry.code_