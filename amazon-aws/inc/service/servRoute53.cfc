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
		
		<cfset var awsKeys = '' />
		<cfset var delegationSet = '' />
		<cfset var hmac = '' />
		<cfset var hostedZone = '' />
		<cfset var modelSerial = '' />
		<cfset var nameServer = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var plugin = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		<cfset var service = '' />
		
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('amazon-aws') />
		<cfset hmac = variables.transport.theApplication.managers.singleton.getHMAC() />
		
		<cfset requestDate = getDate() />
		
		<cfset awsKeys = plugin.getAwsKeys() />
		<cfset service = plugin.getServices().route53 />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<cfset hostedZone = getModel('amazon-aws', 'hostedZone') />
		
		<!--- Before Get Event --->
		<cfset observer.beforeHostedZoneGet(variables.transport, arguments.currUser, arguments.hostedZoneID) />
		
		<cfif len(arguments.hostedZoneID)>
			<!--- Retrieve the hosted zone --->
			<cfhttp method="get" url="https://#service.hostname#/#service.version#/hostedzone/#listLast(arguments.hostedZoneID, '/')#" result="results">
				<cfhttpparam type="header" name="Date" value="#requestDate#" />
				<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#hmac.getSignatureAsBase64(requestDate, awsKeys.secretKey, 'hmacSHA256')#" />
			</cfhttp>
			
			<cfif results.status_code neq 200>
				<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
			</cfif>
			
			<cfset parsed = xmlParse(results.filecontent).xmlroot />
			
			<cfset hostedZone.setHostedZoneID(parsed.hostedZone.id.xmlText) />
			<cfset hostedZone.setName(parsed.hostedZone.name.xmlText) />
			<cfset hostedZone.setCallerReference(parsed.hostedZone.callerReference.xmlText) />
			<cfset hostedZone.setComment(parsed.hostedZone.config.comment.xmlText) />
			
			<cfset delegationSet = {
				'nameServers': []
			} />
			
			<cfloop array="#parsed.delegationSet.nameServers.xmlChildren#" index="nameServer">
				<cfset arrayAppend(delegationSet.nameServers, nameServer.xmlText) />
			</cfloop>
			
			<cfset hostedZone.setDelegationSet(delegationSet) />
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
		<cfset var parsed = '' />
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
			
			<cfset querySetCell(hostedZones, 'hostedZoneID', hostedZone.id.xmlText) />
			<cfset querySetCell(hostedZones, 'name', hostedZone.name.xmlText) />
			<cfset querySetCell(hostedZones, 'callerReference', hostedZone.callerReference.xmlText) />
			<cfset querySetCell(hostedZones, 'comment', hostedZone.config.comment.xmlText) />
		</cfloop>
		
		<cfreturn hostedZones />
	</cffunction>
	
	<cffunction name="setHostedZone" access="public" returntype="string" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="hostedZone" type="component" required="true" />
		
		<cfset var awsKeys = '' />
		<cfset var changeInfo = '' />
		<cfset var delegationSet = '' />
		<cfset var hmac = '' />
		<cfset var nameServer = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var plugin = '' />
		<cfset var requestDate = '' />
		<cfset var requestReference = createUUID() />
		<cfset var requestXml = '' />
		<cfset var results = '' />
		<cfset var service = '' />
		
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('amazon-aws') />
		<cfset hmac = variables.transport.theApplication.managers.singleton.getHMAC() />
		
		<cfset requestDate = getDate() />
		
		<cfset awsKeys = plugin.getAwsKeys() />
		<cfset service = plugin.getServices().route53 />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<!--- Before Save Event --->
		<cfset observer.beforeHostedZoneSave(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<!--- Before Create Event --->
		<cfset observer.beforeHostedZoneCreate(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<!--- Create XMl request --->
		<cfsavecontent variable="requestXml" trim="true">
			<cfoutput>
				<?xml version="1.0" encoding="UTF-8"?>
				<CreateHostedZoneRequest xmlns="https://#service.hostname#/doc/#service.version#/">
					<Name>#arguments.hostedZone.getName()#</Name>
					<CallerReference>#arguments.hostedZone.getCallerReference()#</CallerReference>
					
					<HostedZoneConfig>
						<Comment>#arguments.hostedZone.getComment()#</Comment>
					</HostedZoneConfig>
				</CreateHostedZoneRequest>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Send Create Request --->
		<cfhttp method="post" url="https://#service.hostname#/#service.version#/hostedzone" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#hmac.getSignatureAsBase64(requestDate, awsKeys.secretKey, 'hmacSHA256')#" />
			<cfhttpparam type="body" value="#requestXml#" />
		</cfhttp>
		
		<cfif results.status_code neq '201'>
			<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
		</cfif>
		
		<!--- Pull the data in from the response --->
		<cfset parsed = xmlParse(results.filecontent).xmlroot />
		
		<cfset hostedZone.setHostedZoneID(parsed.hostedZone.id.xmlText) />
		<cfset hostedZone.setName(parsed.hostedZone.name.xmlText) />
		<cfset hostedZone.setCallerReference(parsed.hostedZone.callerReference.xmlText) />
		<cfset hostedZone.setComment(parsed.hostedZone.config.comment.xmlText) />
		
		<cfset changeInfo = {
			'changeInfoID': parsed.changeInfo.id.xmlText,
			'status': parsed.changeInfo.status.xmlText,
			'submittedAt': parsed.changeInfo.submittedAt.xmlText
		} />
		
		<cfset hostedZone.setChangeInfo(changeInfo) />
		
		<cfset delegationSet = {
			'nameServers': []
		} />
		
		<cfloop array="#parsed.delegationSet.nameServers.xmlChildren#" index="nameServer">
			<cfset arrayAppend(delegationSet.nameServers, nameServer.xmlText) />
		</cfloop>
		
		<cfset hostedZone.setDelegationSet(delegationSet) />
		
		<!--- After Create Event --->
		<cfset observer.afterHostedZoneCreate(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<!--- After Save Event --->
		<cfset observer.afterHostedZoneSave(variables.transport, arguments.currUser, arguments.hostedZone) />
		
		<cfreturn requestReference />
	</cffunction>
</cfcomponent>
