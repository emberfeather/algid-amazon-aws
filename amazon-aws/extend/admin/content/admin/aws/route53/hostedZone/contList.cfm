<cfset hostedZones = servRoute53.getHostedZones( filter ) />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(hostedZones.recordcount, session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, hostedZones, viewHostedZone, paginate, filter, { function: 'datagridHostedZone' })#</cfoutput>
