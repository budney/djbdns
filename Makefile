BASENAME=djbdns
BUILDNAME=$(BASENAME)-buildx
TAGS=$(shell ./list-tags.sh)

# PLATFORM can be overridden by the invoker
PLATFORMS ?= linux/386,linux/amd64,linux/amd64/v2,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/riscv64,linux/s390x


define TAG_OPTS
$(shell for tag in $(TAGS); do echo --tag $(LOGNAME)/$(BASENAME):$$tag; done)
endef

.DEFAULT_GOAL := all
.PHONY: all builder prune delete clean distclean

clean: prune
	@if docker buildx ls | grep -q '$(BASENAME)-buildx'; then \
		docker buildx rm $(BASENAME)-buildx; \
	fi

distclean: clean delete

all: builder
	docker buildx build --push --platform $(PLATFORMS) --tag $(LOGNAME)/$(BASENAME):latest $(TAG_OPTS) .

builder:
	@if ! docker buildx ls | grep -q '$(BASENAME)-buildx'; then \
		echo "Creating Buildx instance: $(BASENAME)-buildx"; \
		docker buildx create --use --name=$(BUILDNAME) --driver docker-container --platform $(PLATFORMS) ; \
	else \
		echo "Buildx instance $(BASENAME)-buildx already exists: reusing. Use 'make clean; make' to start fresh."; \
	fi

prune:
	docker buildx prune -f

delete:
	docker buildx rm $(BUILDNAME)
