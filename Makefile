# Journalbeats Makefile
#
# This Makefile contains a collection of targets to help with docker image
# maintenance and creation. Run `make docker-build` to build the docker
# image. Run `make docker-tag` to build the image and tag the docker image
# with the current git tag. Run `make docker-push` to push all tags to docker hub.
#
# Note: This Makefile can be modified to include any future non-docker build
# tasks as well.

IMAGE_NAME := mheese/journalbeat
IMAGE_BUILD_NAME := mheese-journalbeat-build
GIT_BRANCH_NAME := $(shell git rev-parse --abbrev-ref HEAD | sed "sX/X-Xg")
GIT_TAG_NAME := $(shell git describe --tags)

TAGS := $(GIT_BRANCH_NAME) $(GIT_TAG_NAME)

ifeq ($(GIT_BRANCH_NAME),master)
  TAGS += latest
endif

TAGS := $(foreach t,$(TAGS),$(IMAGE_NAME):$(t))

#
# Clean up the project
#
clean:
	rm -rf build
.PHONY: clean

#
# docker tag the image
#
docker-tag: docker-build
	echo $(TAGS) | xargs -n 1 docker tag $(IMAGE_NAME)
.PHONY: docker-tag

#
# docker build the image
#
docker-build:
	docker build -t $(IMAGE_NAME) .
.PHONY: docker-build

#
# docker push all tags
#
docker-push: docker-tag
	echo $(TAGS) | xargs -n 1 docker push
.PHONY: docker-push

#
#  show the current version and branch name, for quick reference.
#
version:
	@echo Version: $(GIT_TAG_NAME)
	@echo Branch: $(GIT_BRANCH_NAME)
.PHONY: version
