#!/bin/bash -e

if [ ! $# -eq 2 ]; then
  echo "Must supply cluster_name (mgmt or wlc-1) and challenge type (http or dns) as args"
  exit 1
fi

cluster_name=$1
challenge_type=$2

LETS_ENCRYPT_ACME_EMAIL=$(yq r params.yaml lets-encrypt-acme-email)

mkdir -p generated/$cluster_name/contour/

# contour-cluster-issuer.yaml
if [ $2 == 'http' ]; then
  yq read tkg-extensions-mods-examples/ingress/contour/contour-cluster-issuer-http.yaml > generated/$cluster_name/contour/contour-cluster-issuer.yaml
fi
if [ $2 == 'dns' ]; then
  yq read tkg-extensions-mods-examples/ingress/contour/contour-cluster-issuer-dns.yaml > generated/$cluster_name/contour/contour-cluster-issuer.yaml
fi
yq write -d0 generated/$cluster_name/contour/contour-cluster-issuer.yaml -i "spec.acme.email" $LETS_ENCRYPT_ACME_EMAIL

kubectl apply -f generated/$cluster_name/contour/contour-cluster-issuer.yaml