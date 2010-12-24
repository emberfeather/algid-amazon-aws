<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="deleteHostedZone" access="public" returntype="component" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="hostedZone" type="component" required="true" />
		
		<cfset var hostedZone = '' />
		<cfset var modelSerial = '' />
		<cfset var observer = '' />
		<cfset var results = '' />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<!--- Before Delete Event --->
		<cfset observer.beforeHostedZoneDelete(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<!--- TODO Delete the hosted zone --->
		
		<!--- After Delete Event --->
		<cfset observer.afterHostedZoneDelete(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<cfreturn hostedZone />
	</cffunction>
	
	<cffunction name="getDate" access="public" returntype="string" output="false">
		<cfset var hostname = '' />
		<cfset var plugin = '' />
		<cfset var result = '' />
		
		<!---
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('amazon-aws') />
		
		<cfset hostname = plugin.getServices().route53.hostname />
		
		<cfhttp method="get" url="http://#hostname#/date" result="result"  />
		
		<!--- TODO Remove --->
		<cfdump var="#result#" />
		--->
		
		<cfreturn getHttpTimestring(now()) />
	</cffunction>
	
	<cffunction name="getHostedZone" access="public" returntype="component" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="hostedZoneID" type="string" required="true" />
		
		<cfset var hostedZone = '' />
		<cfset var modelSerial = '' />
		<cfset var observer = '' />
		<cfset var results = '' />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<cfset hostedZone = getModel('amazon-aws', 'hostedZone') />
		
		<!--- Before Get Event --->
		<cfset observer.beforeHostedZoneGet(variables.transport, arguments.currUser, arguments.hostedZoneID) />
		
		<!--- TODO Retrieve the hosted zone information --->
		
		<cfif 1 eq 0>
			<cfset modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport) />
			
			<cfset modelSerial.deserialize(results, hostedZone) />
		</cfif>
		
		<!--- After Get Event --->
		<cfset observer.afterHostedZoneGet(variables.transport, arguments.currUser, arguments.hostedZoneID) />
		
		<cfreturn hostedZone />
	</cffunction>
	
	<cffunction name="getHostedZones" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var awsKeys = '' />
		<cfset var defaults = {
			isArchived = false,
			orderBy = 'domain',
			orderSort = 'asc'
		} />
		<cfset var elements = '' />
		<cfset var hmac = '' />
		<cfset var hostedZone = '' />
		<cfset var hostedZones = '' />
		<cfset var plugin = '' />
		<cfset var results = '' />
		<cfset var service = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		
		<cfset hostedZones = queryNew('hostedZoneID,name,callerReference,comment') />
		
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('amazon-aws') />
		<cfset hmac = variables.transport.theApplication.managers.singleton.getHMAC() />
		
		<!--- Expand the with defaults --->
		<cfset arguments.filter = extend(defaults, arguments.filter) />
		<cfset requestDate = getDate() />
		
		<cfset awsKeys = plugin.getAwsKeys() />
		<cfset service = plugin.getServices().route53 />
		
		<!--- TODO Retrieve the hosted zones --->
		<cfhttp method="get" url="https://#service.hostname#/#service.version#/hostedzone" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#hmac.getSignatureAsBase64(requestDate, awsKeys.secretKey, 'hmacSHA256')#" />
		</cfhttp>
		
		<cfif results.status_code neq 200>
			<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
		</cfif>
		
		<cfset parsed = xmlParse(results.filecontent).xmlRoot />
		
		<cfloop array="#parsed.hostedZones.xmlChildren#" index="hostedZone">
			<cfset queryAddRow(hostedZones, 1) />
			
			<cfset querySetCell(hostedZones, 'hostedZoneID', hostedZone.id) />
			<cfset querySetCell(hostedZones, 'name', hostedZone.name) />
			<cfset querySetCell(hostedZones, 'callerReference', hostedZone.callerReference) />
			<cfset querySetCell(hostedZones, 'comment', hostedZone.config.comment) />
		</cfloop>
		
		<cfreturn hostedZones />
	</cffunction>
	
	<cffunction name="setHostedZone" access="public" returntype="void" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="hostedZone" type="component" required="true" />
		
		<cfset var observer = '' />
		<cfset var requestXml = '' />
		<cfset var results = '' />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<!--- Before Save Event --->
		<cfset observer.beforeHostedZoneSave(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<cfif arguments.hostedZone.getHostedZoneID() eq ''>
			<!--- Before Create Event --->
			<cfset observer.beforeHostedZoneCreate(variables.transport, arguments.currUser, arguments.hostedZone) />
			<cfsavecontent variable="requestXml">
				<cfoutput>
					<?xml version="1.0" encoding="UTF-8"?>
					<CreateHostedZoneRequest xmlns="https://route53.amazonaws.com/doc/2010-10-01/">
						<Name>#arguments.hostedZone.getName()#</Name>
						<CallerReference>#createUUID()#</CallerReference>
						
						<HostedZoneConfig>
							<Comment>#arguments.hostedZone.getComment()#</Comment>
						</HostedZoneConfig>
					</CreateHostedZoneRequest>
				</cfoutput>
			</cfsavecontent>
			
			<!--- TODO Remove --->
			<cfdump var="#requestXML#" />
			<cfabort />
			
			<!--- TODO Send Create Request --->
			
			<!--- After Create Event --->
			<cfset observer.afterHostedZoneCreate(variables.transport, arguments.currUser, arguments.hostedZone) />
		<cfelse>
			<!--- Before Update Event --->
			<cfset observer.beforeHostedZoneUpdate(variables.transport, arguments.currUser, arguments.hostedZone) />
			
			<!--- TODO Send Update Request --->
			
			<!--- After Update Event --->
			<cfset observer.afterHostedZoneUpdate(variables.transport, arguments.currUser, arguments.hostedZone) />
		</cfif>
		
		<!--- After Save Event --->
		<cfset observer.afterHostedZoneSave(variables.transport, arguments.currUser, arguments.hostedZone) />
	</cffunction>
</cfcomponent>
