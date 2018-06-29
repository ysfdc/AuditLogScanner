global class auditLogScannerCron implements Schedulable {
	global void execute(SchedulableContext sc) {
		auditLogsScanner logScanner = new auditLogsScanner();
		logScanner.parseAuditLogs();
	}
}