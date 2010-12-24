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
	
	<cffunction name="filter" access="public" returntype="string" output="false">
		<cfargument name="values" type="struct" default="#{}#" />
		
		<cfset var filter = '' />
		<cfset var options = '' />
		<cfset var results = '' />
		
		<cfset filter = variables.transport.theApplication.factories.transient.getFilterVertical(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filter.addBundle('plugins/amazon-aws/i18n/inc/view', 'viewRoute53') />
		
		<!--- Search --->
		<cfset filter.addFilter('search') />
		
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
			label = 'hostedZone'
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
