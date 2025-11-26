TF_IN_AUTOMATION := yes
TOFU_CHDIR := $(CURDIR)/opentofu
TOFU_CMD := 'tofu -chdir=$(TOFU_CHDIR)'
TOFU_DEFAULT_ARGS := '-input=false -no-color'
######################################################################

plusserver:
	$(TOFU_CMD) init -upgrade
	 apply -auto-approve \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \
		-var PUBLIC_NETWORK_NAME=ext01

scaleup:
	$(TOFU_CMD) init -upgrade
	$(TOFU_CMD) apply -auto-approve \
		-var PUBLIC_NETWORK_ID=15227829-b53d-48af-b136-85733999252e \
		-var PUBLIC_NETWORK_NAME=public-external
