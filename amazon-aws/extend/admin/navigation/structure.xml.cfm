<navigation>
	<admin>
		<aws position="main">
			<route53 position="main">
				<change position="main"/>
				
				<hostedZone position="main">
					<add position="action"/>
					<delete position="action"/>
					<list position="action"/>
					
					<resourceRecord position="main" vars="hostedZoneID">
						<list position="action" vars="hostedZoneID"/>
						<edit position="action" vars="hostedZoneID"/>
					</resourceRecord>
				</hostedZone>
			</route53>
		</aws>
	</admin>
</navigation>
