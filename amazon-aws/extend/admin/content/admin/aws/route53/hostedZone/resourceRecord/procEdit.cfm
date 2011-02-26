<cfset servRoute53 = services.get('amazon-aws', 'route53') />

<!--- Retrieve the object --->
<cfset hostedZone = servRoute53.getHostedZone(theUrl.search('hostedZoneID')) />
<cfset resourceRecords = servRoute53.getResourceRecords(hostedZone ) />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	
	<cfset changedResourceRecords = [] />
	
	<cfloop list="#form.fieldnames#" index="i">
		<cfset match = reFindNoCase('resourceRecord_([0-9]*)_value', i, 1, true) />
		
		<cfif match.pos[1] and trim(form[i]) neq ''>
			<cfset resourceRecord = servRoute53.getModel('amazon-aws', 'resourceRecord') />
			
			<cfset j = mid(i, match.pos[2], match.len[2]) />
			
			<!--- Make sure that the same name/type gets the records added to existing records --->
			<cfset isFound = false />
			
			<cfloop array="#changedResourceRecords#" index="k">
				<cfif k.getName() eq form['resourceRecord_#j#_name'] and k.getType() eq form['resourceRecord_#j#_type']>
					<cfset isFound = true />
					
					<cfset k.addRecords(form['resourceRecord_#j#_value']) />
					
					<cfbreak />
				</cfif>
			</cfloop>
			
			<cfif not isFound>
				<cfset resourceRecord.setName(form['resourceRecord_#j#_name']) />
				<cfset resourceRecord.setType(form['resourceRecord_#j#_type']) />
				<cfset resourceRecord.setTTL(form['resourceRecord_#j#_ttl']) />
				<cfset resourceRecord.addRecords(form['resourceRecord_#j#_value']) />
				
				<cfset arrayAppend(changedResourceRecords, resourceRecord) />
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- Determine the change batch --->
	<cfset changeBatch = servRoute53.detectChangeResourceRecords(hostedZone, changedResourceRecords) />
	
	<!--- Add change batch comment --->
	<cfset changeBatch.setComment('Adding the A record for the PreHealth Facts domain.') />
	
	<!--- Submit the changes as a batch --->
	<cfset change = servRoute53.setResourceRecords(hostedZone, changeBatch) />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/aws/route53/change') />
	<cfset theURL.setRedirect('changeID', change.getChangeID()) />
	<cfset theURL.removeRedirect('hostedZoneID') />
	
	<cfset theURL.redirectRedirect() />
</cfif>
