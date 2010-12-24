component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Change ID
		addAttribute(
			attribute = 'changeID'
		);
		
		// Status
		addAttribute(
			attribute = 'status'
		);
		
		// Submitted At
		addAttribute(
			attribute = 'submittedAt'
		);
		
		// Set the bundle information for translation
		addBundle('plugins/amazon-aws/i18n/inc/model', 'modChange');
		
		return this;
	}
}
