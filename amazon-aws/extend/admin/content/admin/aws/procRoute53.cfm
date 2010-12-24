<!--- Redirect to the list page until a good reason for this page exists --->
<cfset theURL.setRedirect('_base', '/admin/aws/route53/hostedZone/list') />
<cfset theURL.redirectRedirect() />
