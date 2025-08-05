// Importa o 'fs' para ler ficheiros e o 'path' para construir caminhos
const fs = require('fs');
const path = require('path');

// A função principal que a Vercel irá executar
module.exports = async (request, response) => {
  try {
    // 1. Extrai a mensagem do corpo da requisição enviada pelo Telegram
    const { message } = request.body;

    // Se não houver mensagem ou texto, ignora
    if (!message || !message.text) {
      return response.status(200).send('Mensagem ignorada');
    }

    const perguntaDoCliente = message.text;
    const chatId = message.chat.id;

    // 2. Chama a nossa função de IA para obter uma resposta
    const respostaDaIA = await gerarRespostaComIA(perguntaDoCliente);

    // 3. Envia a resposta de volta para o utilizador através da API do Telegram
    const botToken = process.env.TELEGRAM_BOT_TOKEN; // Obtém o token do ambiente
    const telegramApiUrl = `https://api.telegram.org/bot${botToken}/sendMessage`;

    await fetch(telegramApiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: respostaDaIA,
      }),
    });

    // 4. Responde à Vercel que tudo correu bem
    response.status(200).send('Resposta enviada');

  } catch (error) {
    console.error('Erro no servidor:', error);
    response.status(500).send('Ocorreu um erro interno');
  }
};

// Função que prepara o prompt e chama a IA do Gemini
async function gerarRespostaComIA(pergunta) {
  // Carrega as informações do cardápio do ficheiro JSON
  const jsonPath = path.resolve('./cardapio.json');
  const jsonString = fs.readFileSync(jsonPath, 'utf-8');
  const infoCardapio = JSON.parse(jsonString);

  // Monta o prompt para a IA
  const prompt = `
    Você é um atendente da 'Cafeteria Sabor & Arte'. Use as informações do cardápio abaixo para responder à pergunta do cliente. Seja amigável e conciso.

    CARDÁPIO: ${JSON.stringify(infoCardapio)}
    PERGUNTA: "${pergunta}"
  `;

  // Chama a API do Gemini
  const geminiApiKey = process.env.GEMINI_API_KEY; // Obtém a chave da API do ambiente
  const geminiApiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${geminiApiKey}`;

  const geminiResponse = await fetch(geminiApiUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
    }),
  });

  const geminiData = await geminiResponse.json();

  // Extrai e retorna o texto da resposta da IA
  return geminiData.candidates[0].content.parts[0].text;
}
