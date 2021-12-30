ARCH=amd64
SNAPCAST_VERSION=0.26.0
LIBRESPOT_VERSION=0.3.1
IMAGE_NAME=chiefy/librespot-snapserver

MANIFEST_IMAGE=$(IMAGE_NAME):$(SNAPCAST_VERSION)
LATEST_MANIFEST_IMAGE=$(IMAGE_NAME):latest

ARCH_IMAGE=$(MANIFEST_IMAGE)$(ifneq amd64,$(ARCH),-$(ARCH),)
LATEST_ARCH_IMAGE=$(LATEST_MANIFEST_IMAGE)$(ifneq amd64,$(ARCH),-$(ARCH),)

IMAGE_TEMPLATE=$(MANIFEST_IMAGE)$(ifneq amd64,$(ARCH),-$(ARCH),)
LATEST_IMAGE_TEMPLATE=$(LATEST_MANIFEST_IMAGE)$(ifneq amd64,$(ARCH),-$(ARCH),)

push: build
	docker push $(ARCH_IMAGE)
	docker push $(LATEST_ARCH_IMAGE)
ifeq ($(ARCH),armhf)
	docker push $(MANIFEST_IMAGE)-arm
	docker push $(LATEST_MANIFEST_IMAGE)-arm
endif

build:
	docker build \
	-t $(ARCH_IMAGE) \
	--build-arg ARCH=$(ARCH) \
	--build-arg SNAPCAST_VERSION=$(SNAPCAST_VERSION) \
	--build-arg LIBRESPOT_VERSION=$(LIBRESPOT_VERSION) \
	$(ifneq amd64,$(ARCH),-f Dockerfile.$(ARCH),) \
	.
ifeq ($(ARCH),armhf)
	docker tag $(MANIFEST_IMAGE)-armhf $(MANIFEST_IMAGE)-arm
	docker tag $(LATEST_MANIFEST_IMAGE)-armhf $(LATEST_MANIFEST_IMAGE)-arm
endif

manifest:
	manifest-tool push from-args --platforms linux/amd64,linux/arm --template $(IMAGE_TEMPLATE) --target $(MANIFEST_IMAGE)
	manifest-tool push from-args --platforms linux/amd64,linux/arm --template $(LATEST_IMAGE_TEMPLATE) --target $(LATEST_MANIFEST_IMAGE)
