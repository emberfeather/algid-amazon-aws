component extends="algid.inc.resource.base.modelTest" {
	public void function setup() {
		super.setup();
		
		variables.hostedZone = createObject('component', 'plugins.amazon-aws.inc.model.modHostedZone').init(variables.i18n);
	}
	
	public void function testReturnBlankWhenNotSet() {
		assertEquals('', variables.hostedZone.getName());
	}
	
	public void function testWithTrailingPeriodWhenSetWithTrailingPeriod() {
		variables.hostedZone.setName('test.example.com.');
		
		assertEquals('test.example.com.', variables.hostedZone.getName());
	}
	
	public void function testWithTrailingPeriodWhenSetWithoutTrailingPeriod() {
		variables.hostedZone.setName('my.otherDomain.com');
		
		assertEquals('my.otherDomain.com.', variables.hostedZone.getName());
	}
}
