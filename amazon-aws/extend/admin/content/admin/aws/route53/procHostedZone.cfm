<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	hostedZone = servRoute53.getHostedZone(theUrl.search('hostedZoneID'));
</cfscript>
