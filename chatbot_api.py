from fastapi import FastAPI, Request
from google.cloud import bigquery
from dotenv import load_dotenv
import os

# Inicializa FastAPI **ANTES**
app = FastAPI()

# Carrega variáveis do .env
load_dotenv("C:/Users/Alexandre/OneDrive/Python/_key/.env")
GCP_CREDENTIALS = os.getenv("GCP_KEY_PATH_DESK")

# Inicializa cliente BigQuery
client = bigquery.Client.from_service_account_json(GCP_CREDENTIALS)

@app.post("/bot")
async def responder(req: Request):
    dados = await req.json()
    pergunta = dados.get("pergunta", "").lower().strip()

    query = """
        SELECT resposta
        FROM `vtal-sandbox-engenharia.inventarIA.vw_respostas_bot`
        WHERE LOWER(pergunta) = @pergunta
        LIMIT 1
    """
    job_config = bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("pergunta", "STRING", pergunta)]
    )
    resultado = client.query(query, job_config=job_config).result()

    for row in resultado:
        return {"resposta": row.resposta}

    return {"resposta": "Desculpe, não encontrei uma resposta para essa pergunta."}

# executa localmente apenas
if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("chatbot_api:app", host="0.0.0.0", port=port)
