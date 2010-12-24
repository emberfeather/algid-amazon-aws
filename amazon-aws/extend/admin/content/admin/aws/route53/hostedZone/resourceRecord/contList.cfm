<cfset resourceRecords = servRoute53.getResourceRecords(user, hostedZone, filter) />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(arrayLen(resourceRecords), session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, resourceRecords, viewHostedZone, paginate, filter, { function: 'datagridResourceRecords' })#</cfoutput>
