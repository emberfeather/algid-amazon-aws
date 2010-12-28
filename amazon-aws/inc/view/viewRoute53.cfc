<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="addHostedZone" access="public" returntype="string" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		<cfargument name="request" type="struct" default="#{}#" />
		
		<cfset var i18n = '' />
		<cfset var theForm = '' />
		<cfset var theURL = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset theURL = variables.transport.theRequest.managers.singleton.getUrl() />
		<cfset theForm = variables.transport.theApplication.factories.transient.getFormStandard('hostedZone', i18n) />
		
		<!--- Add the resource bundle for the view --->
		<cfset theForm.addBundle('plugins/amazon-aws/i18n/inc/view', 'viewRoute53') />
		
		<cfset theForm.addElement('text', {
				name = "name",
				label = "hostedZone",
				value = ( structKeyExists(arguments.request, 'name') ? arguments.request.name : arguments.hostedZone.getName() )
			}) />
		
		<cfset theForm.addElement('text', {
				name = "comment",
				label = "comment",
				value = ( structKeyExists(arguments.request, 'comment') ? arguments.request.comment : arguments.hostedZone.getComment() )
			}) />
		
		<cfreturn theForm.toHTML(theURL.get()) />
	</cffunction>
	
	<cffunction name="detailChange" access="public" returntype="string" output="false">
		<cfargument name="change" type="component" required="true" />
		
		<cfset var html = '' />
		
		<!--- TODO Make a nice display of the information for the change --->
		<cfsavecontent variable="html">
			<cfset arguments.change.print() />
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="detailHostedZone" access="public" returntype="string" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		
		<cfset var html = '' />
		
		<!--- TODO Make a nice display of the information for the zone --->
		<cfsavecontent variable="html">
			<cfset arguments.hostedZone.print() />
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="editResourceRecords" access="public" returntype="string" output="false">
		<cfargument name="resourceRecords" type="array" required="true" />
		<cfargument name="request" type="struct" default="#{}#" />
		
		<cfset var counter = '' />
		<cfset var isEditable = '' />
		<cfset var formatted = '' />
		<cfset var options = '' />
		<cfset var record = '' />
		<cfset var records = '' />
		<cfset var resourceRecord = '' />
		<cfset var theURL = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset theURL = variables.transport.theRequest.managers.singleton.getUrl() />
		
		<cfset options = variables.transport.theApplication.factories.transient.getOptions() />
		
		<!--- Create the options for the select --->
		<cfset options.addOption('', '') />
		<cfset options.addOption('A', 'A') />
		<cfset options.addOption('AAAA', 'AAAA') />
		<cfset options.addOption('CNAME', 'CNAME') />
		<cfset options.addOption('MX', 'MX') />
		<cfset options.addOption('NS', 'NS') />
		<cfset options.addOption('PTR', 'PTR') />
		<cfset options.addOption('SOA', 'SOA') />
		<cfset options.addOption('SPF', 'SPF') />
		<cfset options.addOption('SRV', 'SRV') />
		<cfset options.addOption('TXT', 'TXT') />
		
		<cfset counter = 1 />
		
		<cfsavecontent variable="formatted">
			<cfoutput>
				<form class="form" action="#theUrl.get()#" autocomplete="false" method="POST" >
					<table class="datagrid">
						<thead>
							<tr>
								<th class="col name column-0 capitalize">name</th>
								<th class="col ttl column-1 capitalize">TTL</th>
								<th class="col type column-2 capitalize">type</th>
								<th class="col value column-3 capitalize">value</th>
							</tr>
						</thead>
						<tbody>
							<cfloop array="#arguments.resourceRecords#" index="resourceRecord">
								<cfset records = resourceRecord.getRecords() />
								
								<cfloop array="#records#" index="record">
									<cfif resourceRecord.isEditable()>
										<tr>
											<td class="col name column-0">
												<input type="text" name="resourceRecord_#counter#_name" value="#(structKeyExists(arguments.request, 'resourceRecord_#counter#_name') ? arguments.request['resourceRecord_#counter#_name'] : resourceRecord.getName())#" style="width: 200px; min-width: 10px;" />
											</td>
											<td class="col ttl column-1">
												<input type="text" name="resourceRecord_#counter#_ttl" value="#(structKeyExists(arguments.request, 'resourceRecord_#counter#_ttl') ? arguments.request['resourceRecord_#counter#_ttl'] : resourceRecord.getTTL())#" style="width: 50px; min-width: 10px;" />
											</td>
											<td class="col type column-2">
												#formSelect('resourceRecord_#counter#_type', options, (structKeyExists(arguments.request, 'resourceRecord_#counter#_type') ? arguments.request['resourceRecord_#counter#_type'] : resourceRecord.getType()))#
											</td>
											<td class="col value column-3">
												<input type="text" name="resourceRecord_#counter#_value" value="#(structKeyExists(arguments.request, 'resourceRecord_#counter#_name') ? arguments.request['resourceRecord_#counter#_name'] : record)#" style="width: 450px; min-width: 10px;" />
											</td>
										</tr>
									<cfelse>
										<tr>
											<td class="col name column-0">
												#resourceRecord.getName()#
											</td>
											<td class="col ttl column-1">
												#resourceRecord.getTTL()#
											</td>
											<td class="col type column-2">
												#resourceRecord.getType()#
											</td>
											<td class="col value column-3">
												#record#
											</td>
										</tr>
									</cfif>
									
									<cfset counter++ />
								</cfloop>
							</cfloop>
							
							<!--- Add extra rows for new values --->
							<cfloop from="1" to="10" index="i">
								<tr>
									<td class="col name column-0">
										<input type="text" name="resourceRecord_#counter#_name" value="#(structKeyExists(arguments.request, 'resourceRecord_#counter#_name') ? arguments.request['resourceRecord_#counter#_name'] : '')#" style="width: 200px; min-width: 10px;" />
									</td>
									<td class="col ttl column-1">
										<input type="text" name="resourceRecord_#counter#_ttl" value="#(structKeyExists(arguments.request, 'resourceRecord_#counter#_ttl') ? arguments.request['resourceRecord_#counter#_ttl'] : '')#" style="width: 50px; min-width: 10px;" />
									</td>
									<td class="col type column-2">
										#formSelect('resourceRecord_#counter#_type', options, (structKeyExists(arguments.request, 'resourceRecord_#counter#_type') ? arguments.request['resourceRecord_#counter#_type'] : ''))#
									</td>
									<td class="col value column-3">
										<input type="text" name="resourceRecord_#counter#_value" value="#(structKeyExists(arguments.request, 'resourceRecord_#counter#_value') ? arguments.request['resourceRecord_#counter#_value'] : '')#" style="width: 450px; min-width: 10px;" />
									</td>
								</tr>
								
								<cfset counter++ />
							</cfloop>
						</tbody>
					</table>
					
					<div class="submit" >
						<input type="submit" value="submit" />
					</div>
				</form> 
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn formatted />
	</cffunction>
	
	<cffunction name="formSelect" access="private" returntype="string" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="options" type="component" required="true" />
		<cfargument name="value" type="string" required="true" />
		
		<cfset var formatted = '' />
		<cfset var group = '' />
		<cfset var optGroups = '' />
		<cfset var option = '' />
		
		<cfset formatted = '<select name="#arguments.name#">' />
		
		<!--- Get the option groups --->
		<cfset optGroups = arguments.options.get() />
		
		<!--- Output the options --->
		<cfloop array="#optGroups#" index="group">
			<cfloop array="#group.options#" index="option">
				<cfset formatted &= '<option value="' & option.value & '"' />
				
				<!--- Selected --->
				<cfif option.value eq arguments.value>
					<cfset formatted &= ' selected="selected"' />
				</cfif>
				
				<cfset formatted &= '>' & option.title & '</option>' />
			</cfloop>
		</cfloop>
		
		<cfset formatted &= '</select>' />
		
		<cfreturn formatted />
	</cffunction>
	
	<cffunction name="filterActive" access="public" returntype="string" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var filterActive = '' />
		<cfset var options = '' />
		<cfset var results = '' />
		
		<cfset filterActive = variables.transport.theApplication.factories.transient.getFilterActive(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filterActive.addBundle('plugins/amazon-aws/i18n/inc/view', 'viewRoute53') />
		
		<cfreturn filterActive.toHTML(arguments.filter, variables.transport.theRequest.managers.singleton.getURL(), 'search') />
	</cffunction>
	
	<cffunction name="filterResourceRecords" access="public" returntype="string" output="false">
		<cfargument name="values" type="struct" default="#{}#" />
		
		<cfset var filter = '' />
		<cfset var options = '' />
		<cfset var results = '' />
		
		<cfset filter = variables.transport.theApplication.factories.transient.getFilterVertical(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filter.addBundle('plugins/amazon-aws/i18n/inc/view', 'viewRoute53') />
		
		<!--- Name --->
		<cfset filter.addFilter('Name') />
		
		<!--- Type --->
		<cfset options = variables.transport.theApplication.factories.transient.getOptions() />
		
		<cfset options.addOption('Any', '') />
		<cfset options.addOption('A', 'A') />
		<cfset options.addOption('AAAA', 'AAAA') />
		<cfset options.addOption('CNAME', 'CNAME') />
		<cfset options.addOption('MX', 'MX') />
		<cfset options.addOption('NS', 'NS') />
		<cfset options.addOption('PTR', 'PTR') />
		<cfset options.addOption('SOA', 'SOA') />
		<cfset options.addOption('SPF', 'SPF') />
		<cfset options.addOption('SRV', 'SRV') />
		<cfset options.addOption('TXT', 'TXT') />
		
		<cfset filter.addFilter('type', options) />
		
		<cfreturn filter.toHTML(variables.transport.theRequest.managers.singleton.getURL(), arguments.values) />
	</cffunction>
	
	<cffunction name="datagridHostedZone" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		
		<cfset arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL() />
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset datagrid.addBundle('plugins/amazon-aws/i18n/inc/view', 'viewRoute53') />
		
		<cfset datagrid.addColumn({
			key = 'name',
			label = 'hostedZone',
			link = {
				'hostedZoneID' = 'hostedZoneID',
				'_base' = '/admin/aws/route53/hostedZone'
			}
		}) />
		
		<cfset datagrid.addColumn({
			class = 'phantom align-right',
			value = 'delete',
			link = {
				'hostedZoneID' = 'hostedZoneID',
				'_base' = '/admin/aws/route53/hostedZone/delete'
			},
			linkClass = 'delete',
			title = 'hostedZone'
		}) />
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
	
	<cffunction name="datagridResourceRecords" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		
		<cfset arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL() />
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset datagrid.addBundle('plugins/amazon-aws/i18n/inc/view', 'viewRoute53') />
		
		<cfset datagrid.addColumn({
			key = 'name',
			label = 'name'
		}) />
		
		<cfset datagrid.addColumn({
			key = 'type',
			label = 'resourceRecord'
		}) />
		
		<cfset datagrid.addColumn({
			key = 'ttl',
			label = 'ttl'
		}) />
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
</cfcomponent>
