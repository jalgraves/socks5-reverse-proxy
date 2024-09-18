.PHONY: all test clean
SHELL := /bin/bash

# name ?= $(subst _,-,$(@D))
#tag := $(shell grep 'appVersion:' $(@D)/Chart.yaml | cut -f 2 -d' ')
log_level ?= ${SOCKS5_LOG_LEVEL}

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
endif

helm/clean:
		rm *.tgz || true

helm/context:
	kubectl config use-context $(context)

## Publish socks5-reverse-proxy Helm chart
helm/publish:
	cd socks5-reverse-proxy && \
		helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add socks5-reverse-proxy/

## Deploy socks5-reverse-proxy to a cluster
helm/install: helm/context
	@echo "\033[1;32m. . . Installing socks5-reverse-proxy in $(env) . . .\033[1;37m\n"
	cd helm/socks5-reverse-proxy && \
	helm upgrade --install socks5-reverse-proxy . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.name=$(image) \
		--set targetUrl=${TARGET_URL} \
		--set proxy.url=${PROXY_URL} \
		--set proxy.port=${PROXY_PORT} \
		--set tailscale.authKey=${TAILSCALE_AUTH_KEY} \
		--set image.tag=$(image_tag) \
		--set logLevel=$(log_level) \
		--set serviceAccount.name="tailscale" \
		--debug

## Run helm template
helm/template:
	@echo "\033[1;32m. . . Templating socks5-reverse-proxy in $(env) . . .\033[1;37m\n"
	cd helm/socks5-reverse-proxy && \
	helm template . \
		--name-template=$(name) \
		--set global.env=$(env) \
		--set image.name=$(image) \
		--set targetUrl=${TARGET_URL} \
		--set proxy.url=${PROXY_URL} \
		--set proxy.port=${PROXY_PORT} \
		--set tailscale.authKey=${TAILSCALE_AUTH_KEY} \
		--set image.tag=$(image_tag) \
		--set logLevel=$(log_level) \
		--debug

## Forward socks5-reverse-proxy port
helm/port_forward: helm/context
	kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

helm/stop_pf:
	./scripts/stop_port_forward.sh $(port)

helm/logs:
		../scripts/get_pod_logs.sh $(namespace) $(name)

helm/describe:
		../scripts/describe_pod.sh $(namespace) $(name)

## Delete socks5-reverse-proxy pod
helm/kill: helm/context
		./scripts/kill_pod.sh $(namespace) $(name)
