param (
    [string]$CommitMessage
)

if (-not $CommitMessage) {
    Write-Host "Use: .\git-update-push.ps1 -CommitMessage 'Mensagem do commit'"
    exit 1
}

Write-Host "🔄 Atualizando repositório local..."
git pull origin main --rebase

Write-Host "➕ Adicionando mudanças locais..."
git add .

Write-Host "💾 Fazendo commit: $CommitMessage"
git commit -m "$CommitMessage"

Write-Host "🚀 Enviando para o GitHub..."
git push origin main

Write-Host "✅ Atualização e push concluídos!"
