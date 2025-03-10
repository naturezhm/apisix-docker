#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Makefile basic env setting
.DEFAULT_GOAL := help


# APISIX ARGS
APISIX_VERSION ?= 2.10.1
IMAGE_NAME = bradyzm/apisix
IMAGE_TAR_NAME = apache_apisix

APISIX_DASHBOARD_VERSION ?= 2.9.0
APISIX_DASHBOARD_IMAGE_NAME = bradyzm/apisix-dashboard
APISIX_DASHBOARD_IMAGE_TAR_NAME = apache_apisix_dashboard


# Makefile ENV
ENV_OS_NAME                ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ENV_APISIX_TAR_NAME        ?= $(IMAGE_TAR_NAME)_$(APISIX_VERSION)
ENV_APISIX_IMAGE_TAG_NAME  ?= $(IMAGE_NAME):$(APISIX_VERSION)
ENV_DOCKER                 ?= docker


# Makefile basic extension function
_color_red    =\E[1;31m
_color_green  =\E[1;32m
_color_yellow =\E[1;33m
_color_blue   =\E[1;34m
_color_wipe   =\E[0m


define func_echo_status
	printf "[$(_color_blue) info $(_color_wipe)] %s\n" $(1)
endef


define func_echo_warn_status
	printf "[$(_color_yellow) info $(_color_wipe)] %s\n" $(1)
endef


define func_echo_success_status
	printf "[$(_color_green) info $(_color_wipe)] %s\n" $(1)
endef


# Makefile target
### build-on-centos : Build apache/apisix:xx-centos image
.PHONY: build-on-centos
build-on-centos:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-centos -f ./centos/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-on-alpine : Build apache/apisix:xx-alpine image
.PHONY: build-on-alpine
build-on-alpine:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-alpine -f ./alpine/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-on-alpine-local : Build apache/apisix:xx-alpine-local image
# Actually it is not build on certain version but on local code
# Use this name (in the same patterns with others) for convenient CI
.PHONY: build-on-alpine-local
build-on-alpine-local:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-alpine-local --build-arg APISIX_PATH=${APISIX_PATH} -f ./alpine-local/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-on-centos : Push apache/apisix:xx-centos image
# centos not support multiarch since it reply on x86 rpm package
.PHONY: push-on-centos
push-on-centos:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) push $(ENV_APISIX_IMAGE_TAG_NAME)-centos
	$(ENV_DOCKER) build -t $(IMAGE_NAME):latest -f ./centos/Dockerfile .
	$(ENV_DOCKER) push $(IMAGE_NAME):latest
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-on-alpine : Push apache/apisix:xx-alpine image
.PHONY: push-multiarch-on-alpine
push-multiarch-on-alpine:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) buildx build --push \
		-t $(ENV_APISIX_IMAGE_TAG_NAME)-alpine \
		--platform linux/amd64,linux/arm64 \
		-f ./alpine/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-on-alpine-cn : Build apache/apisix:xx-alpine image (for chinese)
.PHONY: build-on-alpine-cn
build-on-alpine-cn:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-alpine --build-arg APISIX_VERSION=$(APISIX_VERSION) --build-arg ENABLE_PROXY=true -f alpine/Dockerfile alpine
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-all-in-one : Build All in one Docker container for Apache APISIX
.PHONY: build-all-in-one
build-all-in-one:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(IMAGE_NAME):whole -f ./all-in-one/apisix/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-centos-tar : tar apache/apisix:xx-centos image
.PHONY: save-centos-tar
save-centos-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(ENV_APISIX_TAR_NAME)-centos.tar $(ENV_APISIX_IMAGE_TAG_NAME)-centos
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-alpine-tar : tar apache/apisix:xx-alpine image
.PHONY: save-alpine-tar
save-alpine-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(ENV_APISIX_TAR_NAME)-alpine.tar $(ENV_APISIX_IMAGE_TAG_NAME)-alpine
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-dashboard : Build apache/dashboard:tag image
.PHONY: build-dashboard
build-dashboard:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION) -f ./dashboard/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-dashboard : Push apache/dashboard:tag image
.PHONY: push-dashboard
push-dashboard:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) push $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)
	$(ENV_DOCKER) build -t $(APISIX_DASHBOARD_IMAGE_NAME):latest -f ./dashboard/Dockerfile .
	$(ENV_DOCKER) push $(APISIX_DASHBOARD_IMAGE_NAME):latest
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-dashboard-tar : tar apache/apisix-dashboard:tag image
.PHONY: save-dashboard-tar
save-dashboard-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(APISIX_DASHBOARD_IMAGE_TAR_NAME)_$(APISIX_DASHBOARD_VERSION).tar $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### help : Show Makefile rules
.PHONY: help
help:
	@$(call func_echo_success_status, "Makefile rules:")
	@echo
	@if [ '$(ENV_OS_NAME)' = 'darwin' ]; then \
		awk '{ if(match($$0, /^#{3}([^:]+):(.*)$$/)){ split($$0, res, ":"); gsub(/^#{3}[ ]*/, "", res[1]); _desc=$$0; gsub(/^#{3}([^:]+):[ \t]*/, "", _desc); printf("    make %-25s : %-10s\n", res[1], _desc) } }' Makefile; \
	else \
		awk '{ if(match($$0, /^\s*#{3}\s*([^:]+)\s*:\s*(.*)$$/, res)){ printf("    make %-25s : %-10s\n", res[1], res[2]) } }' Makefile; \
	fi
	@echo
