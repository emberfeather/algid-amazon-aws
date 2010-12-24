<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	user = transport.theSession.managers.singleton.getUser();
	
	hostedZone = servRoute53.getHostedZone(user, theUrl.search('hostedZoneID'));
	
	if(transport.cgi.request_method eq 'post') {
		// Process the form submission
		modelSerial.deserialize(form, hostedZone);
		
		servRoute53.setHostedZone(user, hostedZone);
	}
</cfscript>
