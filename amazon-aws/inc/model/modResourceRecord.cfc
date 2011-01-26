component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Name
		add__attribute(
			attribute = 'Name'
		);
		
		// Type
		add__attribute(
			attribute = 'type'
		);
		
		// TTL
		add__attribute(
			attribute = 'ttl'
		);
		
		// Records
		add__attribute(
			attribute = 'records',
			defaultValue = []
		);
		
		// Set the bundle information for translation
		add__bundle('plugins/amazon-aws/i18n/inc/model', 'modResourceRecord');
		
		return this;
	}
	
	public boolean function isEditable() {
		var type = this.getType();
		
		switch(type) {
			case 'SOA':
			case 'NS':
				return false;
				
				break;
		}
		
		return true;
	}
	
	public numeric function _compareTo(required component obj) {
		if(this.get__instance().equals(arguments.obj.get__instance())) {
			return 0;
		}
		
		return -1;
	}
}
