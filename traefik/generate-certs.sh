#!/bin/bash

# Crear directorio para certificados si no existe
mkdir -p certs

# Generar la clave privada
openssl genrsa -out certs/local-key.pem 2048

# Generar el certificado autofirmado
openssl req -new -x509 -key certs/local-key.pem -out certs/local-cert.pem -days 3650 -subj "/CN=odoo.local" -addext "subjectAltName = DNS:odoo.local,DNS:*.odoo.local,DNS:localhost,IP:127.0.0.1"

echo "Certificados generados correctamente en el directorio certs/"
echo "Recuerda añadir 'odoo.local' a tu archivo /etc/hosts"
