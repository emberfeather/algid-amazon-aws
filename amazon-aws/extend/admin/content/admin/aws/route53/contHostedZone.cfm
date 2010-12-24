<cfset viewRoute53 = views.get('amazon-aws', 'route53') />

<cfoutput>
	#viewRoute53.detailHostedZone(hostedZone)#
</cfoutput>
