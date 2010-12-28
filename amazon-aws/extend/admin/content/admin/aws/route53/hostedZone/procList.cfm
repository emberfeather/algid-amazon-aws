<cfset servRoute53 = services.get('amazon-aws', 'route53') />

<cfset user = transport.theSession.managers.singleton.getUser() />

<cfif cgi.request_method eq 'post'>
	<!--- Update the URL and redirect --->
	<cfloop list="#form.fieldnames#" index="field">
		<cfset theURL.set('', field, form[field]) />
	</cfloop>
	
	<cfset theURL.redirect() />
</cfif>
