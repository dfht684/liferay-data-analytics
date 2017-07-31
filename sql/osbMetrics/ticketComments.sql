SELECT 
    tc.ticketCommentId,
    SUBSTRING_INDEX(ticketNumber, '-', 1) AS 'accountCode',
    tc.userId AS 'ticketCommentorId',
    tc.userName AS 'ticketCommentor',
    tc.createDate AS 'ticketCommentCreateDate',
    tc.modifiedDate AS 'ticketCommentModifiedDate',
    tc.body,
    tc.format,
    tc.type_,
    tc.visibility,
    tc.status,
    tcd.ticketEntryId,
    tcd.ticketNumber,
    sr.name AS 'SupportRegion'
FROM
    OSB_MetricsTicketComment tc
        LEFT JOIN
    OSB_MetricsTicketCustomData tcd ON tc.ticketEntryId = tcd.ticketEntryId
        LEFT JOIN
    OSB_MetricsTicketEntry te ON te.ticketEntryId = tc.ticketEntryId
        LEFT JOIN
    OSB_MetricsSupportRegion sr ON (sr.supportRegionId = te.supportRegionId)