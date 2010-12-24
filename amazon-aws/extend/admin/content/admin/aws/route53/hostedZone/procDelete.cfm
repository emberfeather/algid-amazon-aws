<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	user = transport.theSession.managers.singleton.getUser();
	
	hostedZone = servRoute53.getHostedZone(user, theUrl.search('hostedZoneID'));
	
	servRoute53.deleteHostedZone(user, hostedZone);
	
	// Add a success message
	transport.theSession.managers.singleton.getSuccess().addMessages('The hosted zone ''' & hostedZone.getName() & ''' was successfully submitted for deletion.');
	
	// Redirect
	theURL.setRedirect('_base', '/admin/aws/route53/hostedZone/list');
	theURL.removeRedirect('hostedZone');
	
	theURL.redirectRedirect();
</cfscript>
