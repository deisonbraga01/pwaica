/**
 * Regenera apenas blocos especificos com estilo clean.
 * Uso: node scripts/gerar-imagens-clean.js
 */

const https = require("https");
const fs = require("fs");
const path = require("path");

const API_URL = "https://n8nwebhookportaine.centralad.com.br/webhook/criar-imagem-for-gemini";
const IMGS_DIR = path.join(__dirname, "..", "imgs");

const baseStyle =
  " Foto realista horizontal em alta qualidade, visual clean, tons claros, baixa saturacao, sem texto, sem logo, sem marca d'agua, iluminacao suave e difusa, estilo premium moderno.";

const targets = [
  {
    file: "bloco4.jpg",
    prompt:
      "Smartphone central com icones financeiros minimalistas ao redor, fundo claro em tons cinza muito suave e bege claro, mesma familia de cor do bloco da pagina, visual com efeito de transparencia e leveza, composicao limpa." +
      baseStyle
  },
  {
    file: "bloco6.jpg",
    prompt:
      "Pessoas usando smartphone e tablet em ambiente moderno, expressao positiva, foco no celular em destaque, luz natural suave, visual clean com tons claros e neutros." +
      baseStyle
  },
  {
    file: "bloco7.jpg",
    prompt:
      "Equipe profissional reunida em mesa com documentos e notebook, ambiente corporativo elegante e clean, tons claros neutros, baixa saturacao, iluminacao suave e uniforme." +
      baseStyle
  }
];

function postAndSave(target) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ prompt: target.prompt });
    const url = new URL(API_URL);

    const req = https.request(
      {
        hostname: url.hostname,
        path: url.pathname + url.search,
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
        }
      },
      (res) => {
        if (res.statusCode !== 200) {
          reject(new Error(target.file + ": status " + res.statusCode));
          return;
        }

        const chunks = [];
        res.on("data", (chunk) => chunks.push(chunk));
        res.on("end", () => {
          const output = path.join(IMGS_DIR, target.file);
          fs.writeFileSync(output, Buffer.concat(chunks));
          console.log("Salvo:", output);
          resolve();
        });
      }
    );

    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

async function main() {
  if (!fs.existsSync(IMGS_DIR)) fs.mkdirSync(IMGS_DIR, { recursive: true });

  for (let i = 0; i < targets.length; i++) {
    const item = targets[i];
    console.log(`Gerando ${item.file} (${i + 1}/${targets.length})...`);
    try {
      await postAndSave(item);
    } catch (e) {
      console.error("Erro", item.file, e.message);
    }
  }

  console.log("Concluido.");
}

main();
