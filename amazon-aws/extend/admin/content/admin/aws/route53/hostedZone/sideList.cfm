<cfset viewHostedZone = views.get('amazon-aws', 'route53') />

<cfset filter = {
		'search' = theURL.search('search')
	} />

<cfoutput>
	#viewHostedZone.filter( filter )#
</cfoutput>
