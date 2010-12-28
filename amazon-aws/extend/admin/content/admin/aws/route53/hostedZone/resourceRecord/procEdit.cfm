<cfset servRoute53 = services.get('amazon-aws', 'route53') />

<!--- Retrieve the object --->
<cfset user = transport.theSession.managers.singleton.getUser() />

<cfset hostedZone = servRoute53.getHostedZone(user, theUrl.search('hostedZoneID')) />
<cfset resourceRecords = servRoute53.getResourceRecords(user, hostedZone ) />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	
	<cfset changedResourceRecords = [] />
	
	<cfloop list="#form.fieldnames#" index="i">
		<cfset match = reFindNoCase('resourceRecord_([0-9]*)_value', i, 1, true) />
		
		<cfif match.pos[1] and trim(form[i]) neq ''>
			<cfset resourceRecord = servRoute53.getModel('amazon-aws', 'resourceRecord') />
			
			<cfset j = mid(i, match.pos[2], match.len[2]) />
			
			<cfset resourceRecord.setName(form['resourceRecord_#j#_name']) />
			<cfset resourceRecord.setType(form['resourceRecord_#j#_type']) />
			<cfset resourceRecord.setTTL(form['resourceRecord_#j#_ttl']) />
			<cfset resourceRecord.addRecords(form['resourceRecord_#j#_value']) />
			
			<cfset arrayAppend(changedResourceRecords, resourceRecord) />
		</cfif>
	</cfloop>
	
	<!--- Determine the change batch --->
	<cfset changeBatch = servRoute53.detectChangeResourceRecords(user, hostedZone, changedResourceRecords) />
	
	<!--- Add change batch comment --->
	<cfset changeBatch.setComment('Adding the A record for the PreHealth Facts domain.') />
	
	<!--- Submit the changes as a batch --->
	<cfset change = servRoute53.setResourceRecords(user, hostedZone, changeBatch) />
	
	<!--- Add a success message --->
	<!--- TODO use i18n --->
	<cfset session.managers.singleton.getSuccess().addMessages('The resource record changes were successfully submitted.') />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/aws/route53/change') />
	<cfset theURL.setRedirect('changeID', change.getChangeID()) />
	<cfset theURL.removeRedirect('hostedZone') />
	
	<cfset theURL.redirectRedirect() />
</cfif>
