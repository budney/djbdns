BASENAME=djbdns
BUILDNAME=$(BASENAME)-buildx
TAGS=$(shell ./list-tags.sh)

define TAG_OPTS
$(shell for tag in $(TAGS); do echo --tag $(LOGNAME)/$(BASENAME):$$tag; done)
endef

.DEFAULT_GOAL := all
.PHONY: all builder prune delete clean distclean

clean: prune

distclean: clean delete

all: builder
	docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag $(LOGNAME)/$(BASENAME):latest $(TAG_OPTS) .

builder:
	docker buildx create --use --name=$(BUILDNAME)

prune:
	docker buildx prune -f 

delete:
	docker buildx rm $(BUILDNAME)
