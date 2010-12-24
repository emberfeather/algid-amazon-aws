component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Name
		addAttribute(
			attribute = 'Name'
		);
		
		// Type
		addAttribute(
			attribute = 'type'
		);
		
		// TTL
		addAttribute(
			attribute = 'ttl'
		);
		
		// Records
		addAttribute(
			attribute = 'records',
			defaultValue = []
		);
		
		// Set the bundle information for translation
		addBundle('plugins/amazon-aws/i18n/inc/model', 'modResourceRecord');
		
		return this;
	}
}
