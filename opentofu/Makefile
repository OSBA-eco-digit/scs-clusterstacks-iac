plusserver:
	tofu init -upgrade
	tofu apply -auto-approve \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \
		-var PUBLIC_NETWORK_NAME=ext01

scaleup:
	tofu init -upgrade
	tofu apply -auto-approve \
		-var PUBLIC_NETWORK_ID=15227829-b53d-48af-b136-85733999252e \
		-var PUBLIC_NETWORK_NAME=public-external
