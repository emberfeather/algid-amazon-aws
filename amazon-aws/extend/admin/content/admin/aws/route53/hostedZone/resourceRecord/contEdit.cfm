<cfset viewRoute53 = views.get('amazon-aws', 'route53') />

<!--- Check for existing paths --->
<cfset filter = {} />

<cfoutput>
	#viewRoute53.editResourceRecords( resourceRecords )#
</cfoutput>
