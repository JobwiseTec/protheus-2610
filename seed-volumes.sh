#!/bin/bash
# Copia, uma única vez, o conteúdo das imagens para ./volume/protheus12 e
# ./volume/dbaccess, para uso com docker-compose.deskflow.yml.
# Usa containers descartáveis criados direto das imagens (não os do compose).
set -e
cd "$(dirname "$0")"
mkdir -p volume/protheus12/bin/appserver volume/protheus12/bin/appserver-exclusivo \
         volume/protheus12/bin/appserver-license volume/protheus12/apo \
         volume/protheus12/protheus_data volume/dbaccess/multi
docker compose --profile exclusivo pull
docker create --platform linux/amd64 --name seed-protheus  emebatista/protheus-2610:latest
docker create --platform linux/amd64 --name seed-license   emebatista/license-server-2610:latest
docker create --platform linux/amd64 --name seed-dbaccess  emebatista/protheus-dbaccess-2610:latest
docker cp seed-protheus:/protheus12/bin/appserver/.  volume/protheus12/bin/appserver/
docker cp seed-protheus:/protheus12/bin/appserver/.  volume/protheus12/bin/appserver-exclusivo/
docker cp seed-license:/protheus12/bin/appserver/.   volume/protheus12/bin/appserver-license/
docker cp seed-protheus:/protheus12/apo/.            volume/protheus12/apo/
docker cp seed-protheus:/protheus12/protheus_data/.  volume/protheus12/protheus_data/
docker cp seed-dbaccess:/dbaccess/multi/.            volume/dbaccess/multi/
docker rm seed-protheus seed-license seed-dbaccess
echo "Pastas ./volume prontas. Suba com: docker compose -f docker-compose.yml -f docker-compose.deskflow.yml up -d"
