#!/usr/bin/make -f

.PHONY: docker
docker:
	docker build -t asf-fast-mode .
