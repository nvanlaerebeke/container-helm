.PHONY: build push

ifeq ($(NAME),)
	echo "NAME not set"
	exit 1
endif

ifeq ($(TAG),)
	echo "TAG not set"
	exit 1
endif

ifeq ($(REPO),)
FULLNAME:=$(NAME):$(TAG)
else
FULLNAME:=$(REPO)/$(NAME):$(TAG)
endif

build: 
	docker build . -t "$(FULLNAME)"

push: build
	docker push "$(FULLNAME)"