# override these
s3bucket ?= "tunes.llolo.lol"
STREAM_URL ?= http://source.my.server:8080/mountpoint.mp3
STREAM_PASS ?= mycoolpassword
# NB if you have weird characters in any of these config vars sed might get mad. should fix that.

TEMPLATE_NAME ?= ice3

run: image
	docker run -ti $(TEMPLATE_NAME)

daemon: image
	docker run -d -t $(TEMPLATE_NAME)

shell: image
	docker run -a stdin -a stdout -i -t $(TEMPLATE_NAME) /bin/bash

image:
	docker build -t $(TEMPLATE_NAME) .

tag: 
	docker tag $(TEMPLATE_NAME):latest revmischa/$(TEMPLATE_NAME)

push: | tag image
	docker push revmischa/$(TEMPLATE_NAME)

push-restart: push
	python restart.py
