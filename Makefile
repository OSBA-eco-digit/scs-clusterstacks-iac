.SILENT:
######################################################################

ANSIBLE_CONFIG := $(CURDIR)/ansible/.ansible.cfg
ANSIBLE_ROLES_PATH := $(CURDIR)/ansible/roles
OS_EXTERNAL_NETWORK_ID := $(OS_EXTERNAL_NETWORK_ID)
OS_CLOUD := $(OS_CLOUD)
TF_IN_AUTOMATION := yes
TF_LOG := INFO
TF_LOG_PATH := $(TOFU_CHDIR)/tofu-$(OS_CLOUD).log
TOFU_CHDIR := $(CURDIR)/opentofu
TOFU_CMD := tofu -chdir=$(TOFU_CHDIR)
TOFU_DEFAULT_ARGS := -input=false -auto-approve -concise -backup="-" -state=$(TOFU_CHDIR)/tofu-$(OS_CLOUD).tfstate
TOFU_DEFAULT_VARS := -var OS_CLOUD=$(OS_CLOUD)
######################################################################

check-env-var-%:
	@ if [ "${${*}}" = "" ]; then \
	  echo "Environment variable $* not set"; \
	  exit 1; \
	fi
######################################################################

ifeq ($(OS_CLOUD),plusserver)
  OS_EXTERNAL_NETWORK_ID := d051c0bd-510c-4da3-bcf3-d8b7082dd008
endif
ifeq ($(OS_CLOUD),scaleup)
  OS_EXTERNAL_NETWORK_ID := 15227829-b53d-48af-b136-85733999252e
endif

export OS_EXTERNAL_NETWORK_ID
######################################################################

all check init validate:
	$(TOFU_CMD) init -upgrade
	$(TOFU_CMD) fmt -check
	$(TOFU_CMD) validate -compact-warnings

setup:
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ANSIBLE_ROLES_PATH=$(ANSIBLE_ROLES_PATH) \
		ansible-playbook -i $(CURDIR)/ansible/inventory_$(OS_CLOUD).ini $(CURDIR)/ansible/playbook.yml
######################################################################

plusserver:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)

plusserver-destroy:
	$(TOFU_CMD) destroy $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)
	find $(CURDIR)/opentofu -name "tofu-$(OS_CLOUD).tfstate" -delete
	rm -f $(CURDIR)/ansible/inventory_$(OS_CLOUD).ini 2>/dev/null

scaleup:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)

scaleup-destroy:
	$(TOFU_CMD) destroy $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)
	find $(CURDIR)/opentofu -name "tofu-$(OS_CLOUD).tfstate" -delete
	rm -f $(CURDIR)/ansible/inventory_scaleup.ini 2>/dev/null
