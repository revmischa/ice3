TCP_PORTS = 80
TCP_FORWARD := $(shell PORT_FORWARD=""; for port in $(TCP_PORTS); do PORT_FORWARD="$$PORT_FORWARD -p $$port:$$port"; done; echo $$PORT_FORWARD)


TEMPLATE_NAME ?= ice3

run: image
	docker run -ti $(TCP_FORWARD) -t $(TEMPLATE_NAME)

daemon: image
	docker run -d $(TCP_FORWARD) -t $(TEMPLATE_NAME)

ports:
	@ echo "forward $(TCP_FORWARD)"

shell: image
	docker run -a stdin -a stdout -i -t $(TEMPLATE_NAME) /bin/bash

image:
	docker build -t $(TEMPLATE_NAME) .

