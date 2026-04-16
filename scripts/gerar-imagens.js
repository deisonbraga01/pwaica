/**
 * Gera imagens via API e salva em imgs/
 * Uso: node scripts/gerar-imagens.js
 * Requer: Node.js com https e fs (padrão)
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const API_URL = 'https://n8nwebhookportaine.centralad.com.br/webhook/criar-imagem-for-gemini';
const IMGS_DIR = path.join(__dirname, '..', 'imgs');

var baseStyle = ' Foto realista horizontal em alta qualidade, sem texto, sem logo, sem marca d\'agua, iluminacao cinematografica suave, foco em tons dourados e neutros, estilo institucional premium.';

var prompts = [
  'Hero banner Banco ICA: casal feliz apontando para cima, ambiente moderno com identidade amarela e dourada, composicao de publicidade para conta digital, estilo clean e premium.' + baseStyle,
  'Ambiente institucional elegante para mensagem do presidente: fundo escuro sofisticado com iluminacao suave, sensacao de autoridade e confianca empresarial.' + baseStyle,
  'Campanha de parceiro e cashback: mulher sorrindo segurando cartao bancario preto e dourado, visual jovem e comercial, fundo amarelo vibrante.' + baseStyle,
  'Smartphone gigante central com icones financeiros ao redor (pagamentos, boletos, pix, transferencias, cashback), splash de agua dinamico e visual tecnologico.' + baseStyle,
  'Conceito de jornada em 3 passos: fundo claro com trilha pontilhada elegante e elementos visuais de progresso digital, visual minimalista de onboarding.' + baseStyle,
  'Cena de pessoas usando smartphone e tablet em casa, conceito de banco digital na palma da mao, atmosfera amigavel e moderna.' + baseStyle,
  'Equipe profissional reunida em mesa com documentos, representando quem somos de uma fintech imobiliaria, clima corporativo confiavel.' + baseStyle,
  'Banner de newsletter e contato: grupo de clientes satisfeitos, visual corporativo claro e moderno com espacos para comunicacao institucional.' + baseStyle
];

function postAndSave(blocoIndex) {
  return new Promise((resolve, reject) => {
    const prompt = prompts[blocoIndex];
    const filename = `bloco${blocoIndex + 1}.jpg`;
    const filepath = path.join(IMGS_DIR, filename);

    const body = JSON.stringify({ prompt });
    const url = new URL(API_URL);
    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body)
      }
    };

    const req = https.request(options, (res) => {
      if (res.statusCode !== 200) {
        reject(new Error(`${filename}: status ${res.statusCode}`));
        return;
      }
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        const buffer = Buffer.concat(chunks);
        fs.writeFileSync(filepath, buffer);
        console.log('Salvo:', filepath);
        resolve();
      });
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

async function main() {
  if (!fs.existsSync(IMGS_DIR)) {
    fs.mkdirSync(IMGS_DIR, { recursive: true });
    console.log('Pasta imgs/ criada.');
  }
  for (let i = 0; i < prompts.length; i++) {
    console.log(`Gerando bloco ${i + 1}/${prompts.length}...`);
    try {
      await postAndSave(i);
    } catch (e) {
      console.error('Erro bloco', i + 1, e.message);
    }
  }
  console.log('Concluído.');
}

main();
