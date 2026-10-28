// Renders tools/icon/icon.svg into the Android launcher icons and the store
// icon (docs/04 U-26). Uses the game's own font and the pre-installed
// Chromium:  node tools/icon/render.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../..');
const svg = fs.readFileSync(path.join(__dirname, 'icon.svg'), 'utf8');
const font = fs.readFileSync(path.join(root, 'app/assets/fonts/PaytoneOne-Regular.ttf')).toString('base64');
const res = path.join(root, 'app/android/app/src/main/res');

// layer: 'full' | 'bg' | 'fg'; scale shrinks the art into the adaptive
// icon's 66/108 safe zone.
function page(size, layer, scale = 1, round = false) {
  let s = svg;
  if (layer === 'fg') s = s.replace(/<g id="bg">[\s\S]*?<\/g>\s*<\/g>|<g id="bg">[\s\S]*?<\/g>/, '');
  if (layer === 'bg') s = s.replace(/<g id="fg"[\s\S]*<\/g>\s*<\/svg>/, '</svg>');
  const inner = (1 - scale) / 2 * 100;
  return `<html><head><style>
    @font-face { font-family: 'Paytone One'; src: url(data:font/ttf;base64,${font}); }
    html, body { margin: 0; background: transparent; }
    .box { width: ${size}px; height: ${size}px; position: relative; overflow: hidden;
           ${round ? 'border-radius: 50%;' : ''} }
    .box svg { position: absolute; left: ${inner}%; top: ${inner}%;
               width: ${scale * 100}%; height: ${scale * 100}%; }
  </style></head><body><div class="box">${s}</div></body></html>`;
}

(async () => {
  const browser = await chromium.launch();
  const p = await browser.newPage({ deviceScaleFactor: 1 });
  async function shot(html, size, out) {
    await p.setViewportSize({ width: size, height: size });
    await p.setContent(html);
    await p.evaluate(() => document.fonts.ready);
    fs.mkdirSync(path.dirname(out), { recursive: true });
    await p.locator('.box').screenshot({ path: out, omitBackground: true });
  }
  const dens = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
  for (const [d, k] of Object.entries(dens)) {
    // Legacy icons (before Android 8): the whole picture, rounded square.
    await shot(page(48 * k, 'full', 0.92), 48 * k, `${res}/mipmap-${d}/ic_launcher.png`);
    // Adaptive layers: 108 dp canvas, art inside the 72 dp safe zone.
    await shot(page(108 * k, 'fg', 0.9), 108 * k, `${res}/mipmap-${d}/ic_launcher_foreground.png`);
    await shot(page(108 * k, 'bg'), 108 * k, `${res}/mipmap-${d}/ic_launcher_background.png`);
  }
  await shot(page(512, 'full'), 512, path.join(root, 'store/icon-512.png'));
  await browser.close();
  console.log('icons written');
})();
