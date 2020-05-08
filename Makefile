# override these
s3bucket ?= "tunes.llolo.lol"
STREAM_URL ?= http://source.my.server:8080/mountpoint.mp3
STREAM_PASS ?= mycoolpassword
# NB if you have weird characters in any of these config vars sed might get mad. should fix that.

build: build-ice3 build-icecast

ICE3_TAG=ice3-klulz
ICECAST_TAG=icecast-klulz

build-ice3:
	docker build --target ice3-klulz --tag $(ICE3_TAG) .

build-icecast:
	docker build --target icecast-klulz --tag $(ICECAST_TAG) .

TEMPLATE_NAME ?= revmischa/klulz

run: image
	docker run $(TEMPLATE_NAME)

daemon: image
	docker run -d -t $(TEMPLATE_NAME)

shell: image
	docker run -a stdin -a stdout -i -t $(TEMPLATE_NAME) /bin/bash

image:
	docker build -t $(TEMPLATE_NAME) .

push: | tag image
	docker push $(TEMPLATE_NAME)

push-restart: push
	python restart.py
