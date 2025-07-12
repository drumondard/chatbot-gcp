#!/bin/bash

# Configurações
PROJECT_ID="vtal-sandbox-engenharia"
REGION="southamerica-east1"
SERVICE_NAME="chatbot-api"
SECRET_NAME="chatbot-key"
ENV_VAR_NAME="GCP_KEY_PATH_DESK"
CONTAINER_IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Iniciando automação do deploy..."

# 1. Ativa o projeto
gcloud config set project $PROJECT_ID

# 2. Concede permissões ao Cloud Build
echo "🔐 Concedendo permissões ao Cloud Build..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/run.admin" --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser" --quiet

# 3. Remove variável de ambiente anterior se necessário
echo "🧹 Limpando variável de ambiente antiga do Cloud Run (se existir)..."
gcloud run services update $SERVICE_NAME \
  --region=$REGION \
  --platform=managed \
  --clear-env-vars=$ENV_VAR_NAME || echo "⚠️ Serviço ainda não existe, seguindo com deploy..."

# 4. Cria o Secret (caso não exista)
echo "🔐 Verificando ou criando o Secret $SECRET_NAME..."
if ! gcloud secrets describe $SECRET_NAME &>/dev/null; then
  echo "✅ Criando Secret $SECRET_NAME..."
  gcloud secrets create $SECRET_NAME --data-file=sua_chave.json
else
  echo "🔁 Secret $SECRET_NAME já existe, pulando criação."
fi

# 5. Dá acesso ao Cloud Run ao Secret
gcloud secrets add-iam-policy-binding $SECRET_NAME \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor" --quiet

# 6. Envia o build com deploy via Cloud Build
echo "📦 Enviando build + deploy com Cloud Build..."
gcloud builds submit --config=cloudbuild.yaml .

echo "✅ Finalizado! Verifique o serviço no Console do Cloud Run."
