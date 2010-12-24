component extends="mxunit.framework.TestCase" {
	public void function setup() {
		variables.i18n = createObject('component', 'cf-compendium.inc.resource.i18n.i18n').init(expandPath('/'));
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
