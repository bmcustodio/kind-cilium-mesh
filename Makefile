SHELL := /bin/bash

ROOT := $$(git rev-parse --show-toplevel)

.PHONY: run

run:
	$(ROOT)/kind-cilium-mesh-up.sh
