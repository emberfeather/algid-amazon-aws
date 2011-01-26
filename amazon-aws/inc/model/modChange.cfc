component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Change ID
		add__attribute(
			attribute = 'changeID'
		);
		
		// Status
		add__attribute(
			attribute = 'status'
		);
		
		// Submitted At
		add__attribute(
			attribute = 'submittedAt'
		);
		
		// Set the bundle information for translation
		add__bundle('plugins/amazon-aws/i18n/inc/model', 'modChange');
		
		return this;
	}
}
