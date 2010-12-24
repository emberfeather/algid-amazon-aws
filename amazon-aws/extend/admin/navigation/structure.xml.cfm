<navigation>
	<admin>
		<aws position="main">
			<route53 position="main">
				<change position="main"/>
				
				<hostedZone position="main">
					<add position="action"/>
					<delete position="action"/>
					<list position="action"/>
					
					<resourceRecord position="main" vars="hostedZone">
						<list position="action" vars="hostedZone"/>
						<edit position="action" vars="hostedZone"/>
					</resourceRecord>
				</hostedZone>
			</route53>
		</aws>
	</admin>
</navigation>
