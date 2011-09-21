<cfset hostedZones = servRoute53.getHostedZones() />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(hostedZones.recordcount, session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, hostedZones, viewHostedZone, paginate, {}, { function: 'datagridHostedZone' })#</cfoutput>
