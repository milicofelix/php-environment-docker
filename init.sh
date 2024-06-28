#!/bin/bash

# Função para verificar se um nó Redis está pronto
check_redis_ready() {
  local host=$1
  local port=$2
  until redis-cli -h $host -p $port ping &> /dev/null; do
    echo "Aguardando $host:$port estar pronto..."
    sleep 1
  done
  echo "$host:$port está pronto."
}

# Verificar se todos os nós Redis estão prontos
echo "Verificando se os nós Redis estão prontos..."
check_redis_ready setup-redis-spedtax 6379
check_redis_ready setup-cluster-2-spedtax 6380
check_redis_ready setup-cluster-3-spedtax 6381
check_redis_ready setup-cluster-4-spedtax 6382
check_redis_ready setup-cluster-5-spedtax 6383
check_redis_ready setup-cluster-6-spedtax 6384

# Criar o cluster Redis
echo "Criando o cluster Redis..."
redis-cli --cluster create \
  setup-redis-spedtax:6379 \
  setup-cluster-2-spedtax:6380 \
  setup-cluster-3-spedtax:6381 \
  setup-cluster-4-spedtax:6382 \
  setup-cluster-5-spedtax:6383 \
  setup-cluster-6-spedtax:6384 \
  --cluster-replicas 1 \
  --cluster-yes

# Verificar o status do cluster
echo "Verificando o status do cluster Redis..."
redis-cli -h setup-redis-spedtax -p 6379 cluster nodes