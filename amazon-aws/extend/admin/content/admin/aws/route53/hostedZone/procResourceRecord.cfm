<!--- Redirect to the list page until a good reason for this page exists --->
<cfset theURL.setRedirect('_base', '/admin/aws/route53/hostedZone/resourceRecord/list') />
<cfset theURL.redirectRedirect() />
