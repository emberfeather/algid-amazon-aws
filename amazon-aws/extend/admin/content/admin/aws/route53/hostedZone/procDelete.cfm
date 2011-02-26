<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	hostedZone = servRoute53.getHostedZone(theUrl.search('hostedZoneID'));
	
	change = servRoute53.deleteHostedZone(hostedZone);
	
	// Redirect
	theURL.setRedirect('_base', '/admin/aws/route53/change');
	theURL.setRedirect('changeID', change.getChangeID());
	theURL.removeRedirect('hostedZoneID');
	
	theURL.redirectRedirect();
</cfscript>
