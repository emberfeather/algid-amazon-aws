<cfset servRoute53 = services.get('amazon-aws', 'route53') />

<cfset hostedZone = servRoute53.getHostedZone(theUrl.search('hostedZoneID')) />

<cfif cgi.request_method eq 'post'>
	<!--- Update the URL and redirect --->
	<cfloop list="#form.fieldnames#" index="field">
		<cfset theURL.set('', field, form[field]) />
	</cfloop>
	
	<cfset theURL.redirect() />
</cfif>
