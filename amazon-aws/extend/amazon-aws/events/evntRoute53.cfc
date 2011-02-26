component extends="algid.inc.resource.base.event" {
	public void function afterHostedZoneCreate( required struct transport, required component hostedZone ) {
		// Add success message
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The hosted zone ''' & arguments.hostedZone.getName() & ''' was successfully submitted for creation.');
	}
	
	public void function afterHostedZoneDelete( required struct transport, required component hostedZone ) {
		// Add success message
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The hosted zone ''' & arguments.hostedZone.getName() & ''' was successfully submitted for deletion.');
	}
	
	public void function afterResourceRecordSave( required struct transport, required component hostedZone ) {
		// Add success message
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The resource record changes for the hosted zone ''' & arguments.hostedZone.getName() & ''' were successfully submitted for update.');
	}
}
