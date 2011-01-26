<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	user = transport.theSession.managers.singleton.getUser();
	
	hostedZone = servRoute53.getHostedZone(user, theUrl.search('hostedZoneID'));
	
	if(transport.theCgi.request_method eq 'post') {
		// Process the form submission
		modelSerial.deserialize(form, hostedZone);
		
		change = servRoute53.setHostedZone(user, hostedZone);
		
		// Redirect
		theURL.setRedirect('_base', '/admin/aws/route53/change');
		theURL.setRedirect('changeID', change.getChangeID());
		theURL.removeRedirect('hostedZoneID');
		
		theURL.redirectRedirect();
	}
</cfscript>
