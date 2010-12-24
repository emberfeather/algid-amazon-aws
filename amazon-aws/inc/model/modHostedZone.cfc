component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Hosted Zone ID
		addAttribute(
			attribute = 'hostedZoneID'
		);
		
		// Comment
		addAttribute(
			attribute = 'comment'
		);
		
		// Name
		addAttribute(
			attribute = 'name'
		);
		
		// Set the bundle information for translation
		addBundle('plugins/amazon-aws/i18n/inc/model', 'modHostedZone');
		
		return this;
	}
	
	public void function setName(required string value) {
		if (len(arguments.value) and right(arguments.value, 1) neq '.') {
			arguments.value &= '.';
		}
		
		super.setName(arguments.value);
	}
}
