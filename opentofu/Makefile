all:
	tofu init -upgrade
	tofu plan
	tofu apply -auto-approve \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \
		-var PUBLIC_NETWORK_NAME=ext01
