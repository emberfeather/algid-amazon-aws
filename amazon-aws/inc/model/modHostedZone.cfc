component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Hosted Zone ID
		add__attribute(
			attribute = 'hostedZoneID'
		);
		
		// Caller Reference
		add__attribute(
			attribute = 'callerReference',
			defaultValue = createUUID()
		);
		
		// Change Information
		add__attribute(
			attribute = 'change'
		);
		
		// Comment
		add__attribute(
			attribute = 'comment'
		);
		
		// Delegation Set
		add__attribute(
			attribute = 'delegationSet',
			defaultValue = {}
		);
		
		// Name
		add__attribute(
			attribute = 'name'
		);
		
		// Set the bundle information for translation
		add__bundle('plugins/amazon-aws/i18n/inc/model', 'modHostedZone');
		
		return this;
	}
	
	public void function setName(required string value) {
		if (len(arguments.value) and right(arguments.value, 1) neq '.') {
			arguments.value &= '.';
		}
		
		super.setName(arguments.value);
	}
}
