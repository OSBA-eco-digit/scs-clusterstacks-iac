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
  OS_AUTH_URL := https://scs2.api.pco.get-cloud.io:5000
  OS_EXTERNAL_NETWORK_ID := d051c0bd-510c-4da3-bcf3-d8b7082dd008
endif
ifeq ($(OS_CLOUD),scaleup)
  OS_AUTH_URL := https://keystone.scs1.scaleup.cloud:443
  OS_EXTERNAL_NETWORK_ID := 15227829-b53d-48af-b136-85733999252e
endif

export OS_AUTH_URL
export OS_EXTERNAL_NETWORK_ID
######################################################################

#
# default targets
#

all check init validate:
	$(TOFU_CMD) init -upgrade
	$(TOFU_CMD) fmt -check
	$(TOFU_CMD) validate -compact-warnings

destroy:
	$(TOFU_CMD) destroy $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)
	find $(CURDIR)/opentofu -name "tofu-$(OS_CLOUD).tfstate" -delete
	rm -f "$(CURDIR)/ansible/inventory_$(OS_CLOUD).ini" 2>/dev/null

setup:
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ANSIBLE_ROLES_PATH=$(ANSIBLE_ROLES_PATH) \
		ansible-playbook -i $(CURDIR)/ansible/inventory_$(OS_CLOUD).ini $(CURDIR)/ansible/playbook.yml

setup-kind:
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ANSIBLE_ROLES_PATH=$(ANSIBLE_ROLES_PATH) \
		ansible-playbook -i $(CURDIR)/ansible/inventory_$(OS_CLOUD).ini -e k3s_apply_role=false $(CURDIR)/ansible/playbook.yml

scripts-only:
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ANSIBLE_ROLES_PATH=$(ANSIBLE_ROLES_PATH) \
		ansible-playbook -i $(CURDIR)/ansible/inventory_$(OS_CLOUD).ini -e scripts_only=true $(CURDIR)/ansible/playbook.yml

ssh:
	echo ssh $(shell (grep ssh_args $(CURDIR)/ansible/.ansible.cfg | cut -d'=' -f2-)) \
	-l $(shell (awk '{print $3}' ansible/inventory_scaleup.ini | awk -F'=' '{print $2}')) \
	$(shell (awk '{print $2}' ansible/inventory_scaleup.ini | awk -F'=' '{print $2}'))
######################################################################

#
# providers
#

plusserver:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)

scaleup:
	$(TOFU_CMD) apply $(TOFU_DEFAULT_ARGS) $(TOFU_DEFAULT_VARS) -var PUBLIC_NETWORK_ID=$(OS_EXTERNAL_NETWORK_ID)
