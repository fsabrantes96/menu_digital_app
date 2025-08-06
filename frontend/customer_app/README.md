# ☕ Cardápio Digital App (Full Stack)

Este repositório contém o código completo para um sistema de cardápio digital para uma cafeteria, incluindo o aplicativo do cliente (frontend) e o chatbot de atendimento (backend).

## 📂 Estrutura do Projeto

O projeto está organizado num monorepo com duas pastas principais:

* **/frontend**: Contém o aplicativo móvel desenvolvido em Flutter. É a interface que os clientes usam no tablet do estabelecimento.
* **/backend**: Contém o servidor serverless (Node.js) para o chatbot do Telegram, integrado com a IA do Gemini e hospedado na Vercel.

---

### 📱 Frontend (Flutter App)

O aplicativo permite que os clientes visualizem o cardápio, façam pedidos e paguem a conta.

**Para executar o frontend:**
```bash
# Navegue até à pasta do frontend
cd frontend

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run

# Navegue até à pasta do backend
cd backend

# Faça o deploy para a Vercel
vercel --prod

🛠️ Tecnologias Utilizadas
Frontend: Flutter, Dart, sqflite

Backend: Node.js, Vercel, Telegram Bot API

Inteligência Artificial: Google Gemini

Feito por Felipe Abrantes.