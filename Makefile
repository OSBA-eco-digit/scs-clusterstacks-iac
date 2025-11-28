TF_IN_AUTOMATION := yes
TOFU_CHDIR := $(CURDIR)/opentofu
TOFU_CMD := tofu -chdir=$(TOFU_CHDIR)
TOFU_DEFAULT_ARGS := -input=false -auto-approve -concise -backup="-"
######################################################################

check-env-var-%:
	@ if [ "${${*}}" = "" ]; then \
	  echo "Environment variable $* not set"; \
	  exit 1; \
	fi
######################################################################

.PHONY: all check init validate
all: check init validate
	$(TOFU_CMD) fmt
	$(TOFU_CMD) validate -compact-warnings
	$(TOFU_CMD) init -upgrade
######################################################################

.PHONY: plusserver
plusserver:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \
		-state=$(TOFU_CHDIR)/tofu-plusserver.tfstate

.PHONY: plusserver-destroy
plusserver-destroy:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=d051c0bd-510c-4da3-bcf3-d8b7082dd008 \
		-state=$(TOFU_CHDIR)/tofu-plusserver.tfstate
		-destroy
######################################################################

.PHONY: scaleup
scaleup:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=15227829-b53d-48af-b136-85733999252e \
		-state=$(TOFU_CHDIR)/tofu-scaleup.tfstate

.PHONY: scaleup-destroy
scaleup-destroy:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) \
		-var OS_CLOUD=$(OS_CLOUD) \
		-var PUBLIC_NETWORK_ID=15227829-b53d-48af-b136-85733999252e \
		-state=$(TOFU_CHDIR)/tofu-scaleup.tfstate
		-destroy
