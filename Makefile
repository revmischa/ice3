# override these
s3bucket ?= "tunes.llolo.lol"
stream_uri ?= http://source.my.server:8080/mountpoint.mp3
stream_pass ?= mycoolpassword
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

push: image
	docker tag $(TEMPLATE_NAME):latest revmischa/$(TEMPLATE_NAME)
	docker push revmischa/$(TEMPLATE_NAME)
