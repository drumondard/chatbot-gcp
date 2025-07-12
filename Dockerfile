# Imagem base oficial do Python
FROM python:3.11-slim

# Define diretório de trabalho
WORKDIR /app

# Copia os arquivos da aplicação
COPY . .

# Instala dependências
RUN pip install --no-cache-dir -r requirements.txt

# Expõe a porta 8080
EXPOSE 8080

# Comando para iniciar a aplicação na porta 8080
CMD ["uvicorn", "chatbot_api:app", "--host", "0.0.0.0", "--port", "8080"]

