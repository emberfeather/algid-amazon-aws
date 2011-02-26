<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="init" access="public" returntype="component" output="false">
		<cfargument name="transport" type="struct" required="true" />
		
		<cfset var plugin = '' />
		
		<cfset super.init( argumentCollection = arguments ) />
		
		<cfset variables.hmac = variables.transport.theApplication.managers.singleton.getHMAC() />
		
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('amazon-aws') />
		
		<cfset variables.awsKeys = plugin.getAwsKeys() />
		<cfset variables.service = plugin.getServices().route53 />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="deleteHostedZone" access="public" returntype="struct" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		
		<cfset var change = '' />
		<cfset var delegationSet = '' />
		<cfset var hostedZone = '' />
		<cfset var modelSerial = '' />
		<cfset var nameServer = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		
		<cfset requestDate = getDate() />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<!--- Before Delete Event --->
		<cfset observer.beforeHostedZoneDelete(variables.transport, arguments.hostedZone) />
		
		<!--- Send Delete Request --->
		<cfhttp method="delete" url="https://#variables.service.hostname#/#variables.service.version#/hostedzone/#listLast(arguments.hostedZone.getHostedZoneID(), '/')#" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
		</cfhttp>
		
		<cfif results.status_code neq '200'>
			<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
		</cfif>
		
		<!--- Pull the data in from the response --->
		<cfset parsed = xmlParse(results.filecontent).xmlroot />
		
		<cfset change = getModel('amazon-aws', 'change') />
		
		<cfset change.setChangeID(parsed.changeInfo.id.xmlText) />
		<cfset change.setStatus(parsed.status.id.xmlText) />
		<cfset change.setSubmittedAt(parsed.submittedAt.id.xmlText) />
		
		<!--- After Delete Event --->
		<cfset observer.afterHostedZoneDelete(variables.transport, arguments.hostedZone) />
		
		<cfreturn change />
	</cffunction>
	
	<cffunction name="detectChangeResourceRecords" access="public" returntype="component" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		<cfargument name="resourceRecords" type="array" required="true" />
		
		<cfset var changeBatch = '' />
		<cfset var isMatch = '' />
		<cfset var originResourceRecords = '' />
		<cfset var i = '' />
		<cfset var j = '' />
		
		<cfset changeBatch = getModel('amazon-aws', 'changeBatch') />
		
		<cfset originResourceRecords = getResourceRecords(arguments.hostedZone) />
		
		<!--- Check if there are any origin records that were not matching in the new records --->
		<cfloop array="#originResourceRecords#" index="i">
			<cfset isMatch = false />
			
			<cfif not i.isEditable()>
				<!--- Don't try to match non-editable types --->
				<cfset isMatch = true />
			<cfelse>
				<cfloop array="#arguments.resourceRecords#" index="j">
					<cfif i._compareTo(j) eq 0>
						<cfset isMatch = true />
						
						<cfbreak />
					</cfif>
				</cfloop>
			</cfif>
			
			<cfif !isMatch>
				<cfset changeBatch.addResourceRecords('DELETE', i) />
			</cfif>
		</cfloop>
		
		<!--- Check if there are any new records that were not matching the origin records --->
		<cfloop array="#arguments.resourceRecords#" index="i">
			<cfset isMatch = false />
			
			<cfloop array="#originResourceRecords#" index="j">
				<cfif i._compareTo(j) eq 0>
					<cfset isMatch = true />
					
					<cfbreak />
				</cfif>
			</cfloop>
			
			<cfif !isMatch>
				<cfset changeBatch.addResourceRecords('CREATE', i) />
			</cfif>
		</cfloop>
		
		<cfreturn changeBatch />
	</cffunction>
	
	<cffunction name="getChange" access="public" returntype="component" output="false">
		<cfargument name="changeID" type="string" required="true" />
		
		<cfset var delegationSet = '' />
		<cfset var change = '' />
		<cfset var modelSerial = '' />
		<cfset var nameServer = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		
		<cfset requestDate = getDate() />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<cfset change = getModel('amazon-aws', 'change') />
		
		<!--- Before Get Event --->
		<cfset observer.beforeChangeGet(variables.transport, arguments.changeID) />
		
		<!--- Retrieve the change --->
		<cfhttp method="get" url="https://#variables.service.hostname#/#variables.service.version#/change/#listLast(arguments.changeID, '/')#" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
		</cfhttp>
		
		<cfif results.status_code neq 200>
			<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
		</cfif>
		
		<cfset parsed = xmlParse(results.filecontent).xmlroot />
		
		<cfset change.setChangeID(parsed.changeInfo.id.xmlText) />
		<cfset change.setStatus(parsed.changeInfo.status.xmlText) />
		<cfset change.setSubmittedAt(parsed.changeInfo.submittedAt.xmlText) />
		
		<!--- After Get Event --->
		<cfset observer.afterChangeGet(variables.transport, arguments.changeID) />
		
		<cfreturn change />
	</cffunction>
	
	<cffunction name="getDate" access="public" returntype="string" output="false">
		<!--- TODO replace with web service call to get the date to be on the same time as the server --->
		
		<cfreturn getHttpTimestring(now()) />
	</cffunction>
	
	<cffunction name="getHostedZone" access="public" returntype="component" output="false">
		<cfargument name="hostedZoneID" type="string" required="true" />
		
		<cfset var delegationSet = '' />
		<cfset var hostedZone = '' />
		<cfset var modelSerial = '' />
		<cfset var nameServer = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		
		<cfset requestDate = getDate() />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<cfset hostedZone = getModel('amazon-aws', 'hostedZone') />
		
		<!--- Before Get Event --->
		<cfset observer.beforeHostedZoneGet(variables.transport, arguments.hostedZoneID) />
		
		<cfif len(arguments.hostedZoneID)>
			<!--- Retrieve the hosted zone --->
			<cfhttp method="get" url="https://#variables.service.hostname#/#variables.service.version#/hostedzone/#listLast(arguments.hostedZoneID, '/')#" result="results">
				<cfhttpparam type="header" name="Date" value="#requestDate#" />
				<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
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
		<cfset observer.afterHostedZoneGet(variables.transport, arguments.hostedZoneID) />
		
		<cfreturn hostedZone />
	</cffunction>
	
	<cffunction name="getHostedZones" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var defaults = {
			'maxItems': 100
		} />
		<cfset var elements = '' />
		<cfset var hostedZone = '' />
		<cfset var hostedZones = '' />
		<cfset var parsed = '' />
		<cfset var results = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		
		<cfset hostedZones = queryNew('hostedZoneID,name,callerReference,comment') />
		
		<!--- Expand the with defaults --->
		<cfset arguments.filter = extend(defaults, arguments.filter) />
		
		<cfset requestDate = getDate() />
		
		<!--- Retrieve the hosted zones --->
		<cfhttp method="get" url="https://#variables.service.hostname#/#variables.service.version#/hostedzone" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
			<cfhttpparam type="url" name="maxItems" value="#arguments.filter.maxItems#" />
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
	
	<cffunction name="getResourceRecords" access="public" returntype="array" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var defaults = {
			'name': '',
			'type': '',
			'maxItems': 100
		} />
		<cfset var element = '' />
		<cfset var resourceRecord = '' />
		<cfset var resourceRecords = [] />
		<cfset var resourceRecordSet = '' />
		<cfset var parsed = '' />
		<cfset var queryString = '' />
		<cfset var results = '' />
		<cfset var requestDate = '' />
		<cfset var results = '' />
		
		<!--- Expand the with defaults --->
		<cfset arguments.filter = extend(defaults, arguments.filter) />
		
		<cfset requestDate = getDate() />
		
		<!--- Retrieve the resource records --->
		<cfhttp method="get" url="https://#variables.service.hostname#/#variables.service.version#/hostedzone/#listLast(arguments.hostedZone.getHostedZoneID(), '/')#/rrset" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
			<cfhttpparam type="url" name="maxitems" value="#arguments.filter.maxItems#" />
			
			<cfif arguments.filter.name neq ''>
				<cfhttpparam type="url" name="name" value="#arguments.filter.name#" />
				
				<!--- Type only works if you also declare a name --->
				<cfif arguments.filter.type neq ''>
					<cfhttpparam type="url" name="type" value="#arguments.filter.type#" />
				</cfif>
			</cfif>
		</cfhttp>
		
		<cfif results.status_code neq 200>
			<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
		</cfif>
		
		<cfset parsed = xmlParse(results.filecontent).xmlRoot />
		
		<cfloop array="#parsed.resourceRecordSets.xmlChildren#" index="resourceRecordSet">
			<cfset resourceRecord = getModel('amazon-aws', 'resourceRecord') />
			
			<cfset resourceRecord.setName(resourceRecordSet.name.xmlText) />
			<cfset resourceRecord.setType(resourceRecordSet.type.xmlText) />
			<cfset resourceRecord.setTTL(resourceRecordSet.ttl.xmlText) />
			
			<cfloop array="#resourceRecordSet.resourceRecords.xmlChildren#" index="element">
				<cfset resourceRecord.addRecords(element.value.xmlText) />
			</cfloop>
			
			<cfset arrayAppend(resourceRecords, resourceRecord) />
		</cfloop>
		
		<cfreturn resourceRecords />
	</cffunction>
	
	<cffunction name="setHostedZone" access="public" returntype="component" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		
		<cfset var change = '' />
		<cfset var delegationSet = '' />
		<cfset var nameServer = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var requestDate = '' />
		<cfset var requestReference = createUUID() />
		<cfset var requestXml = '' />
		<cfset var results = '' />
		
		<cfset requestDate = getDate() />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<!--- Before Save Event --->
		<cfset observer.beforeHostedZoneSave(variables.transport, arguments.hostedZone) />
		
		<!--- Before Create Event --->
		<cfset observer.beforeHostedZoneCreate(variables.transport, arguments.hostedZone) />
		
		<!--- Create XMl request --->
		<cfsavecontent variable="requestXml" trim="true">
			<cfoutput>
				<?xml version="1.0" encoding="UTF-8"?>
				<CreateHostedZoneRequest xmlns="https://#variables.service.hostname#/doc/#variables.service.version#/">
					<Name>#arguments.hostedZone.getName()#</Name>
					<CallerReference>#arguments.hostedZone.getCallerReference()#</CallerReference>
					
					<HostedZoneConfig>
						<Comment>#arguments.hostedZone.getComment()#</Comment>
					</HostedZoneConfig>
				</CreateHostedZoneRequest>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Send Create Request --->
		<cfhttp method="post" url="https://#variables.service.hostname#/#variables.service.version#/hostedzone" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
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
		
		<cfset change = getModel('amazon-aws', 'change') />
		
		<cfset change.setChangeID(parsed.changeInfo.id.xmlText) />
		<cfset change.setStatus(parsed.status.id.xmlText) />
		<cfset change.setSubmittedAt(parsed.submittedAt.id.xmlText) />
		
		<cfset hostedZone.setChange(change) />
		
		<cfset delegationSet = {
			'nameServers': []
		} />
		
		<cfloop array="#parsed.delegationSet.nameServers.xmlChildren#" index="nameServer">
			<cfset arrayAppend(delegationSet.nameServers, nameServer.xmlText) />
		</cfloop>
		
		<cfset hostedZone.setDelegationSet(delegationSet) />
		
		<!--- After Create Event --->
		<cfset observer.afterHostedZoneCreate(variables.transport, arguments.hostedZone) />
		
		<!--- After Save Event --->
		<cfset observer.afterHostedZoneSave(variables.transport, arguments.hostedZone) />
		
		<cfreturn change />
	</cffunction>
	
	<cffunction name="setResourceRecords" access="public" returntype="component" output="false">
		<cfargument name="hostedZone" type="component" required="true" />
		<cfargument name="changeBatch" type="component" required="true" />
		
		<cfset var change = '' />
		<cfset var changes = '' />
		<cfset var i = '' />
		<cfset var j = '' />
		<cfset var observer = '' />
		<cfset var parsed = '' />
		<cfset var requestDate = '' />
		<cfset var requestReference = createUUID() />
		<cfset var requestXml = '' />
		<cfset var records = '' />
		<cfset var results = '' />
		
		<cfset requestDate = getDate() />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('amazon-aws', 'route53') />
		
		<!--- Before Save Event --->
		<cfset observer.beforeResourceRecordSave(variables.transport, arguments.hostedZone, arguments.changeBatch) />
		
		<cfset changes = arguments.changeBatch.getResourceRecords() />
		
		<!--- Make sure we have something to change --->
		<cfif not arrayLen(changes)>
			<cfthrow type="validation" message="No changes to submit" detail="There were no changes from the existing resource records" />
		</cfif>
		
		<!--- Create XMl request --->
		<cfsavecontent variable="requestXml" trim="true">
			<cfoutput>
				<?xml version="1.0" encoding="UTF-8"?>
				<ChangeResourceRecordSetsRequest xmlns="https://#variables.service.hostname#/doc/#variables.service.version#/">
					<ChangeBatch>
						<Comment>
							<![CDATA[
								#arguments.changeBatch.getComment()#
							]]>
						</Comment>
						<Changes>
							<cfloop array="#changes#" index="i">
								<Change>
									<Action>#i.action#</Action>
									<ResourceRecordSet>
										<Name>#i.resourceRecord.getName()#</Name>
										<Type>#i.resourceRecord.getType()#</Type>
										<TTL>#i.resourceRecord.getTTL()#</TTL>
										<ResourceRecords>
											<cfset records = i.resourceRecord.getRecords() />
											
											<cfloop array="#records#" index="j">
												<ResourceRecord>
													<Value>#j#</Value>
												</ResourceRecord>
											</cfloop>
										</ResourceRecords>
									</ResourceRecordSet>
								</Change>
							</cfloop>
						</Changes>
					</ChangeBatch>
				</ChangeResourceRecordSetsRequest>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Send Batch Request --->
		<cfhttp method="post" url="https://#variables.service.hostname#/#variables.service.version#/hostedzone/#listLast(arguments.hostedZone.getHostedZoneID(), '/')#/rrset" result="results">
			<cfhttpparam type="header" name="Date" value="#requestDate#" />
			<cfhttpparam type="header" name="X-Amzn-Authorization" value="AWS3-HTTPS AWSAccessKeyId=#variables.awsKeys.accessKeyID#,Algorithm=HmacSHA256,Signature=#variables.hmac.getSignatureAsBase64(requestDate, variables.awsKeys.secretKey, 'hmacSHA256')#" />
			<cfhttpparam type="body" value="#requestXml#" />
		</cfhttp>
		
		<cfif results.status_code neq '200'>
			<cfthrow message="Unable to complete web service call" detail="Server responded with a #results.status_code# status" extendedinfo="#results.filecontent#" />
		</cfif>
		
		<!--- Pull the data in from the response --->
		<cfset parsed = xmlParse(results.filecontent).xmlroot />
		
		<cfset change = getModel('amazon-aws', 'change') />
		
		<cfset change.setChangeID(parsed.changeInfo.id.xmlText) />
		<cfset change.setStatus(parsed.changeInfo.status.xmlText) />
		<cfset change.setSubmittedAt(parsed.changeInfo.submittedAt.xmlText) />
		
		<cfset hostedZone.setChange(change) />
		
		<!--- After Save Event --->
		<cfset observer.afterResourceRecordSave(variables.transport, arguments.hostedZone, arguments.changeBatch) />
		
		<cfreturn change />
	</cffunction>
</cfcomponent>
