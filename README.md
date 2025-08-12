☕ Cardápio Digital com Assistente de IA
Este repositório contém o código-fonte completo de um sistema de cardápio digital full-stack, desenvolvido como um projeto pessoal de estudo. A solução é composta por duas aplicações frontend em Flutter e um backend serverless para um chatbot com Inteligência Artificial.

📂 Estrutura do Projeto
O projeto está organizado num monorepo, contendo as seguintes pastas na sua raiz:

/frontend: Contém as duas aplicações Flutter.

customer_app: A aplicação para o cliente, que roda no tablet do estabelecimento.

admin_app: O painel de gestão para os funcionários, que pode ser executado em telemóveis, tablets ou desktops.

/backend: Contém o servidor serverless (Node.js) para o chatbot do Telegram, integrado com a IA do Gemini e pronto para ser hospedado na Vercel.

✨ Funcionalidades Principais
📱 Aplicação do Cliente (customer_app)
Identificação de Sessão: O cliente inicia o pedido inserindo o seu nome e número da mesa.

Cardápio Visual: Exibição dos produtos com imagens, descrições e preços, lidos em tempo real do Firestore.

Carrinho de Compras: Adição e gestão de itens no pedido.

Envio de Pedidos: Envio dos pedidos diretamente para a cozinha.

Integração com Assistente Virtual: Um botão com QR Code permite que o cliente use o seu próprio telemóvel para conversar com um bot no Telegram e tirar dúvidas.

💼 Aplicação de Gestão (admin_app)
Login Seguro: Acesso ao painel protegido por e-mail e palavra-passe com o Firebase Authentication.

Dashboard de Pedidos em Tempo Real: Visualização instantânea de novos pedidos assim que são enviados pelos clientes.

Notificações Sonoras e Visuais: Alerta sonoro e destaque visual para cada novo pedido, garantindo que a cozinha nunca perca uma nova ordem.

Identificação Clara: Cada pedido no painel exibe o nome do cliente e o número da mesa, facilitando a entrega.

🤖 Assistente Virtual (Backend)
Inteligência Artificial: Utiliza a API do Google Gemini para entender as perguntas dos clientes em linguagem natural.

Base de Conhecimento: Responde a dúvidas sobre ingredientes, preços, alergénios e horários, com base num ficheiro de dados do cardápio.

Plataforma Gratuita: Integrado com a API de Bots do Telegram, permitindo uma automação robusta sem os custos associados à API do WhatsApp.

Arquitetura Serverless: Hospedado na Vercel, garantindo escalabilidade e baixo custo de manutenção.

🛠️ Tecnologias Utilizadas
Área

Tecnologia

Frontend

Flutter, Dart

Base de Dados

Cloud Firestore (Banco de Dados em Tempo Real)

Autenticação

Firebase Authentication (Login e Senha)

Backend (Chatbot)

Node.js, Vercel (Hospedagem Serverless)

IA & Automação

Google Gemini API, Telegram Bot API

🚀 Como Executar
Frontend
Navegue para a pasta da aplicação desejada (frontend/customer_app ou frontend/admin_app).

Instale as dependências: flutter pub get

Execute a aplicação: flutter run

Backend
Navegue para a pasta backend.

Faça o deploy para a Vercel: vercel --prod

Configure as variáveis de ambiente (TELEGRAM_BOT_TOKEN e GEMINI_API_KEY) no painel da Vercel.

Configure o webhook do seu bot do Telegram para apontar para a URL da sua função na Vercel.

Este projeto é de minha autoria e foi desenvolvido como uma demonstração prática das minhas competências em desenvolvimento de software full-stack.

Felipe Abrantes
