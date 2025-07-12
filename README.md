# Chatbot FastAPI com Deploy Automático no Google Cloud Run

Este repositório contém um chatbot desenvolvido em FastAPI que consulta dados de views no BigQuery e é implantado automaticamente no Google Cloud Run via Cloud Build.

---

## Estrutura do Projeto

- `chatbot_api.py` — Código principal da API FastAPI.
- `Dockerfile` — Imagem Docker para o serviço.
- `requirements.txt` — Dependências Python.
- `cloudbuild.yaml` — Configuração do Cloud Build para CI/CD.
- `script.sh` — Script auxiliar para deploy manual.
- `.gitignore` — Arquivos ignorados pelo Git.

---

## Pré-requisitos

- Conta no Google Cloud Platform com projeto configurado.
- Google Cloud SDK instalado e autenticado.
- Repositório GitHub conectado ao Cloud Build para deploy automático.
- Secret Manager com a chave de serviço do GCP criada (nome: `chatbot-key`).

---

## Configuração Inicial

1. **Criar o Secret Manager com a chave da conta de serviço:**

```bash
gcloud secrets create chatbot-key --data-file=sua_chave.json
