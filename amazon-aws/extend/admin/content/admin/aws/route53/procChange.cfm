<cfscript>
	servRoute53 = services.get('amazon-aws', 'route53');
	
	change = servRoute53.getChange(theUrl.search('changeID'));
</cfscript>
