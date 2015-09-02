#!/usr/bin/env bash

unset DOCKER_CERT_PATH
unset DOCKER_TLS_VERIFY
export DOCKER_HOST=tcp://vagrant.f8:2375
export KUBERNETES_NAMESPACE=default
export KUBERNETES_MASTER=https://vagrant.f8:8443
export KUBERNETES_DOMAIN=vagrant.f8
export KUBERNETES_TRUST_CERT="true"