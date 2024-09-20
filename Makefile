-include \
	helm/socks5-reverse-proxy/Makefile

.PHONY: all test clean

export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)
SHELL := /bin/bash

MAKE_FILES = \
	${MAKE_PATH}/Makefile \
	${MAKE_PATH}/helm/socks5-reverse-proxy/Makefile

name ?= socks5-reverse-proxy
image ?= $(name)
env ?= dev
port ?= 5004
tag ?= $(shell yq eval '.info.version' swagger.yaml)
hash = $(shell git rev-parse --short HEAD)
repository ?= jalgraves

ifeq ($(env),dev)
	image_tag = $(tag)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ifeq ($(env),prod)
    image_tag = $(tag)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
else
	env := dev
endif

context:
	kubectl config use-context $(context)

compile:
	cp requirements.txt prev-requirements.txt || true
	pip-compile -r -U requirements.in

build:
	@echo "\033[1;32m. . . Building Menu API image . . .\033[1;37m\n"
	docker build --platform linux/x86_64 -t $(image):$(image_tag) .

build_no_cache:
	docker build -t $(image) . --no-cache=true

publish: build
	docker tag $(image):$(image_tag) $(repository)/$(image):$(image_tag)
	docker push $(repository)/$(image):$(image_tag)

latest: build
	docker tag $(image):$(image_tag) $(repository)/$(image):latest
	docker push $(repository)/$(image):latest

redis:
	docker run -d --name red -p "6379:6379" --restart always redis

clean:
	rm -rf api/__pycache__ || true
	rm .DS_Store || true
	rm api/*.pyc

## Start docker container
docker/run:
	docker run \
		--rm \
		--name $(name) \
		-p $(port):$(port) \
		--env TARGET_URL=${TARGET_URL} \
		--env PROXY_URL=${PROXY_URL} \
		--env PROXY_PORT=${PROXY_PORT} \
		--env LOG_LEVEL="INFO" \
		$(name):$(image_tag)


docker/run/ts:
	docker run \
		--rm \
		--name ts \
		--cap-add "NET_ADMIN" \
		--cap-add "sys_module" \
		--env TS_AUTHKEY=${TAILSCALE_AUTH_KEY} \
		--env TS_USERSPACE="true" \
		--env TS_HOSTNAME="tailscale-test" \
		--env TS_OUTBOUND_HTTP_PROXY_LISTEN=":1055" \
		--env TS_SOCKS5_SERVER=":1055" \
		--env TS_EXTRA_ARGS="--accept-routes" \
		tailscale/tailscale:latest

## Reset the database
reset_db: context
	${HOME}/github/helm/scripts/kill_pod.sh ${DATABASE_NAMESPACE} postgres

kill_pod: context
	${HOME}/github/helm/scripts/kill_pod.sh $(env) $(name)

kill_port_forward: context
	${HOME}/github/helm/scripts/stop_port_forward.sh $(port)

restart: kill_pod kill_port_forward

## Show available commands
help:
	@printf "Available targets:\n\n"
	@$(SELF) -s help/generate | grep -E "\w($(HELP_FILTER))"
	@printf "\n\n"

help/generate:
	@awk '/^[a-zA-Z\_0-9%:\\\/-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKE_FILES) | sort -u
