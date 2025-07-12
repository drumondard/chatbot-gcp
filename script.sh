#!/bin/bash

# Configurações
PROJECT_ID="vtal-sandbox-engenharia"
REGION="southamerica-east1"
SERVICE_NAME="chatbot-api"
SECRET_NAME="chatbot-key"
ENV_VAR_NAME="GCP_KEY_PATH_DESK"
KEY_FILE="vtal-sandbox-engenharia-094305d08334.json"
CONTAINER_IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME"

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

echo "${GREEN}🚀 Iniciando automação do deploy...${RESET}"

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

# 3. Remove variável de ambiente anterior (se existir)
echo "🧹 Limpando variável de ambiente antiga do Cloud Run (se existir)..."
gcloud run services update $SERVICE_NAME \
  --region=$REGION \
  --platform=managed \
  --clear-env-vars=$ENV_VAR_NAME || echo "⚠️ Serviço ainda não existe, prosseguindo..."

# 4. Cria o Secret (caso não exista)
echo "🔐 Verificando ou criando o Secret $SECRET_NAME..."
if ! gcloud secrets describe $SECRET_NAME &>/dev/null; then
  if [[ ! -f "$KEY_FILE" ]]; then
    echo "${RED}❌ Arquivo de chave '$KEY_FILE' não encontrado. Abortando...${RESET}"
    exit 1
  fi
  echo "✅ Criando Secret $SECRET_NAME..."
  gcloud secrets create $SECRET_NAME --data-file=$KEY_FILE
else
  echo "🔁 Secret $SECRET_NAME já existe, pulando criação."
fi

# 5. Dá acesso ao Cloud Run ao Secret (para conta padrão e personalizada)
echo "🔐 Garantindo acesso ao Secret..."
for sa in \
  "${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  "service-inventario-rede@${PROJECT_ID}.iam.gserviceaccount.com"
do
  gcloud secrets add-iam-policy-binding $SECRET_NAME \
    --member="serviceAccount:$sa" \
    --role="roles/secretmanager.secretAccessor" --quiet
done

# 6. Envia o build com deploy via Cloud Build
echo "📦 Enviando build + deploy com Cloud Build..."
gcloud builds submit --config=cloudbuild.yaml .

echo "${GREEN}✅ Finalizado! Verifique o serviço no Console do Cloud Run.${RESET}"
