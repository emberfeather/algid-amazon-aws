component extends="algid.inc.resource.plugin.configure" {
	public void function onApplicationStart(required struct theApplication) {
		var temp = '';
		
		if(! arguments.theApplication.managers.singleton.hasHMAC()) {
			temp = createObject('component', 'cf-compendium.inc.resource.security.hmac').init()
			
			arguments.theApplication.managers.singleton.setHMAC(temp)
		}
	}
}
