public class auditLogsScanner {

	// lookback period
	private static integer lookbackHoursPeriod = -1;
	// List of Salesforce user ids to send the email to
	private static List<String> sendEmailto = 
		new List<String> {''};
	// List of sections to ignore from the audit log events
	private static Set<String> ignoreSections = 
		new Set<String> {'Manage Users', 'Custom Tabs'};
	// List of users to monitor
	private static List<String> usersToMonitor = 
		new List<String> {''};
	// Email subject
	private static String emailSubject = 'Unexpected Change has occured in Production';	
	
	/*
		Sends an email to the Salesforce users defined by sendEmailTo

		@param body
		List of Strings to create the body of the email
	*/
	public void sendEmailMessage(List<String> body) {
		if (body == NULL || body.isEmpty()) {
			return;
		}

		// Construct the Single Email Message
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.toAddresses = sendEmailto;
		message.subject = emailSubject;
		String messageBody = String.join(body, '\n\n');
		message.plainTextBody = messageBody;

		try {
			// Do not check for errors as nothing to do in that case
			// We just want to bail out gracefully
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
		} catch(System.CalloutException e) {
			System.debug('ERROR:' + e);
		}
	}

	/*
		Get the audit log events that occured in a lookback 
		period and were triggered by specific users
		
		The default lookback period (lookbackHoursPeriod) is one hour
		This method calls sendEmailMessage to send an email with the events
	*/
	public void parseAuditLogs() {
		DateTime dt = System.Now().addHours(lookbackHoursPeriod);

		// run SOQL on SetupAuditTrail filtering on UserName and CreatedDate
		List<SetupAuditTrail> queryResults = [SELECT CreatedDate, CreatedBy.UserName, 
											  Action, Section, Display 
											  FROM SetupAuditTrail 
											  WHERE CreatedBy.UserName IN :usersToMonitor 
											  		AND CreatedDate >=:dt 
											  ORDER BY CreatedDate DESC];
		if (queryResults.isEmpty()) {
			return;
		}

		// parse the query to build the body for the email
		List<String> emailBodyList = new List<String>();
		for (SetupAuditTrail log: queryResults) {
			if (ignoreSections.contains(log.section)) {
				continue;
			}

			String emailLine = 'User: ' + log.CreatedBy.UserName 
							   + ' Section: ' + log.Section + ' Action: ' 
							   + log.Action + ' Details: ' + log.Display;
			emailBodyList.add(emailLine);
		}
		if (!emailBodyList.isEmpty()) {
			sendEmailMessage(emailBodyList);
		}
	}
}