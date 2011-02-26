<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	hostedZone = servRoute53.getHostedZone(theUrl.search('hostedZoneID'));
	
	if(transport.theCgi.request_method eq 'post') {
		// Process the form submission
		modelSerial.deserialize(form, hostedZone);
		
		change = servRoute53.setHostedZone(hostedZone);
		
		// Redirect
		theURL.setRedirect('_base', '/admin/aws/route53/change');
		theURL.setRedirect('changeID', change.getChangeID());
		theURL.removeRedirect('hostedZoneID');
		
		theURL.redirectRedirect();
	}
</cfscript>
