import requests

# URL da sua API no Cloud Run
API_URL = "https://chatbot-api-344405088425.southamerica-east1.run.app/bot"

# Lista de perguntas de teste
testes = [
    "qual o prazo de instalação?",
    "como solicito suporte?",
    "quais os tipos de tecnologia?",
    "endereço de atendimento?",
    "não sei"
]

def testar_chatbot():
    print(f"🔍 Testando API: {API_URL}\n")
    for pergunta in testes:
        print(f"🧠 Pergunta: {pergunta}")
        try:
            resp = requests.post(API_URL, json={"pergunta": pergunta})
            if resp.status_code == 200:
                print("✅ Resposta:", resp.json().get("resposta"))
            else:
                print("❌ Erro:", resp.status_code, resp.text)
        except Exception as e:
            print("⚠️ Erro de conexão:", e)
        print("-" * 50)

if __name__ == "__main__":
    testar_chatbot()
