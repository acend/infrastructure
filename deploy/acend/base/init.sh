#!/bin/bash

NAMESPACE="acend-website"
SECRET_NAME="acend-events-secrets.yaml"

if [ -f "$SECRET_NAME" ]; then
    echo "File $SECRET_NAME already exist!"
else
    PASS=$(openssl rand -base64 15)
    echo "Password created: $PASS"
    kubectl -o yaml --dry-run=client -n "$NAMESPACE" \
        create secret generic mariadb-pass --from-literal=password="$PASS" \
        | kubeseal --controller-name sealed-secrets -o yaml > "$SECRET_NAME"
fi
