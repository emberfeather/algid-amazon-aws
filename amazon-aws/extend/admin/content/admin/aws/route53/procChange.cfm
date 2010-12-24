<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	user = transport.theSession.managers.singleton.getUser();
	
	change = servRoute53.getChange(user, theUrl.search('changeID'));
</cfscript>
