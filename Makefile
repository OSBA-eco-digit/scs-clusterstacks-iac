TF_IN_AUTOMATION := yes
TOFU_CHDIR := $(CURDIR)/opentofu
TOFU_CMD := tofu -chdir=$(TOFU_CHDIR)
TOFU_DEFAULT_ARGS := -input=false -no-color -auto-approve -concise -backup="-"
######################################################################

check-env-var-%:
	@ if [ "${${*}}" = "" ]; then \
	  echo "Environment variable $* not set"; \
	  exit 1; \
	fi
######################################################################

.PHONY: plusserver
plusserver:
	$(TOFU_CMD) init -upgrade
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \

.PHONY: plusserver-destroy
plusserver-destroy:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \
		-destroy
	find . -iname .terraform -delete
######################################################################

.PHONY: scaleup
scaleup:
	$(TOFU_CMD) init -upgrade
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=15227829-b53d-48af-b136-85733999252e \

.PHONY: scaleup-destroy
scaleup-destroy:
	$(TOFU_CMD) init -upgrade
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=15227829-b53d-48af-b136-85733999252e \
		-destroy
	find . -iname .terraform -delete
