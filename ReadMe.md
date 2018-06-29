## Overview and Business Case: 
https://sf9to5.com/2018/06/28/monitor-setup-audit-trail-email-alerts/

## Usage 
* The auditLogScanner class should be used in conjuntion with the auditLogScannerCron
* The Cron can either be intialized from the Developer Console or through a trigger
	* If using a trigger make sure to take precautions that you will not reach the governor limits
* There are 4 static variables that you will need to define in order for the class to run
	* The lookback period
	* The Salesforce User Ids to send the emails to 
	* The Sections, if any, that should be ignored
	* The Usernames to filter the SOQL results on
 

## auditLogScanner.cls

A class that contains a method that runs a query over the SetUpAuditTrail object 
and returns results based on the pre-defined filters.
The results of teh query are then pass to sendEmailMessage method, 
to generate an email to the specified users.

## auditLogScannerCron.cls

This is a scheduable class that invokes the auditLogScanner class
The Scheduler used was: 

	System.schedule('Scheduled Job 1', '0 0 * * * ?', new auditLogScannerCron ());


## Test Cases

* Sending to multiple users
* Monitoring multiple users
* Different lookback periods
* Different Section filtering