#!/bin/bash

# Mensagem do commit passada como parâmetro
COMMIT_MSG=$1

if [ -z "$COMMIT_MSG" ]; then
  echo "Use: ./git-update-push.sh \"Mensagem do commit\""
  exit 1
fi

# Atualiza o repositório local com o remoto
echo "🔄 Atualizando repositório local..."
git pull origin main --rebase

# Adiciona todas as mudanças locais
echo "➕ Adicionando mudanças locais..."
git add .

# Faz commit com a mensagem passada
echo "💾 Fazendo commit: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# Envia para o repositório remoto
echo "🚀 Enviando para o GitHub..."
git push origin main

echo "✅ Atualização e push concluídos!"
