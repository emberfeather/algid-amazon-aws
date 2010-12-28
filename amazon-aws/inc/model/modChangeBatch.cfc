component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Comment
		addAttribute(
			attribute = 'comment'
		);
		
		// Resource Records
		addAttribute(
			attribute = 'resourceRecords',
			defaultValue = []
		);
		
		// Set the bundle information for translation
		addBundle('plugins/amazon-aws/i18n/inc/model', 'modChangeBatch');
		
		return this;
	}
	
	public void function addResourceRecords(required string action, required component resourceRecord) {
		var i = '';
		
		for( i = 2; i <= arrayLen(arguments); i++ ) {
			super.addResourceRecords({
				'action': arguments.action,
				'resourceRecord': arguments[i]
			});
		}
	}
}
