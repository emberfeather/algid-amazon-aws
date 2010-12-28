<cfset viewHostedZone = views.get('amazon-aws', 'route53') />

<cfset filter = {
	'type' = theUrl.search('type'),
	'name' = theUrl.search('name')
} />

<cfoutput>
	#viewHostedZone.filterResourceRecords( filter )#
</cfoutput>