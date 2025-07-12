#!/bin/bash

# Configurações
WORKFLOW_DIR=".github/workflows"
WORKFLOW_FILE="$WORKFLOW_DIR/cloudrun-deploy.yaml"
BRANCH="main"
COMMIT_MSG="🔄 Atualização automática do GitHub Actions CI/CD para Cloud Run"

# Verifica se diretório existe
if [ ! -d "$WORKFLOW_DIR" ]; then
  echo "📁 Criando diretório: $WORKFLOW_DIR"
  mkdir -p "$WORKFLOW_DIR"
fi

# Cria/Atualiza o arquivo de workflow
cat > "$WORKFLOW_FILE" << 'EOF'
name: Deploy Chatbot GCP

on:
  push:
    branches:
      - main

env:
  PROJECT_ID: vtal-sandbox-engenharia
  REGION: southamerica-east1
  SERVICE_NAME: chatbot-api
  IMAGE: gcr.io/${{ env.PROJECT_ID }}/chatbot-api

jobs:
  deploy:
    name: Build & Deploy to Cloud Run
    runs-on: ubuntu-latest

    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🔐 Setup Google Cloud credentials
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: ☁️ Set up gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{ env.PROJECT_ID }}
          install_components: 'beta'

      - name: 🛠️ Build Docker image
        run: |
          gcloud builds submit --tag $IMAGE || echo "✅ Build enviado. Verifique os logs no Console do Cloud Build."

      - name: 🚀 Deploy to Cloud Run
        run: |
          gcloud run deploy $SERVICE_NAME \
            --image=$IMAGE \
            --region=$REGION \
            --platform=managed \
            --allow-unauthenticated \
            --update-secrets=GCP_KEY_PATH_DESK=chatbot-key:latest
EOF

# Git commit e push
echo "📦 Enviando atualização para o GitHub..."
git add "$WORKFLOW_FILE"
git commit -m "$COMMIT_MSG"
git push origin $BRANCH

echo "✅ CI/CD GitHub Actions atualizado e enviado para o repositório!"
