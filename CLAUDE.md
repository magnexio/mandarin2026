# Repaso de Chino (mandarin2026)

Web app para repasar vocabulario de mandarín con los compañeros de clase. Todo vive en un único `index.html`, sin backend.
Publicada en GitHub Pages: https://magnexio.github.io/mandarin2026/ (repo `magnexio/mandarin2026`, rama `main`).

## Filosofía (no romperla)
- **Fricción cero:** no hay menús, puntuaciones ni pantalla de inicio. Al abrir la web empieza directamente una ronda aleatoria.
- Si aciertas, explosión de partículas y pasas a la siguiente ronda. Si fallas, una tarjeta muestra la respuesta (carácter + pinyin + español) unos 2,8 s y pasa a la siguiente.
- Pensada para el móvil: abrir, jugar un minuto y cerrar.
- Estética china tradicional: fondo granate oscuro, luz cálida de linternas, dorados, fichas Mahjong.
- La interfaz está en español. El usuario aprende chino en clase, con compañeros (véase `NAMES`).

## Stack
- three.js 0.160 (ES modules vía importmap desde jsDelivr), con postproceso: bloom (UnrealBloomPass) + OutputPass con tono ACES.
- GSAP 3.12.5 (cdnjs) para todas las animaciones.
- Web Speech API para pronunciar en chino (`zh-CN`). Si una frase empieza por un nombre latino («Lorea，你好吗？»), el nombre se lee con voz `es-ES` y el resto en chino.
- SFX sintetizados con Web Audio (escala pentatónica).
- Fuentes de Google: Noto Serif SC (caracteres), Noto Serif (pinyin), Inter (interfaz).
- El texto de los objetos 3D se dibuja con Canvas 2D a texturas de 512–1024 px (`layoutGlyph` centra según la caja real del glifo).

## Dónde tocar en `index.html`
- `VOCAB`: vocabulario `{ espanol, chino, pinyin }`. Los 10 primeros deben ser los números 一 a 十, porque `NUMS = VOCAB.slice(0, 10)`.
- `CONFUSABLE`: caracteres parecidos, que se usan como distractores.
- `PHRASES`: frases de conversación como tokens `[carácter, pinyin]`, para poder dejar huecos. `REPLIES` define qué respuestas son válidas o inválidas para cada frase (nunca debe haber dos correctas entre las opciones). `WORDS` son las fichas del ejercicio de completar.
- `NAMES`: compañeros de clase. Aparecen en «(nombre)，你好吗？».
- `MODES`: registro de modos. `w` es el peso (cuántas veces más sale) y `ok()` indica si está disponible.

## Modos (bucle aleatorio, nunca el mismo dos veces seguidas)
| clave | sello | ejercicio | función |
|---|---|---|---|
| tiles | 字 | español → carácter (fichas Mahjong 2×2) | `roundTiles()` |
| pyChar | 拼 | pinyin → carácter | `roundTiles(true)` |
| meaning | 义 | carácter → español (ficha + 4 placas) | `roundMeaning()` |
| orbit | 音 | carácter → pinyin (moneda dorada + linternas en órbita, variantes de tono) | `roundOrbit()` |
| pyNum | 拼 | número 11–99 → pinyin (placas, errores típicos) | `roundPlaques()` |
| numbers | 数 | construir el número 11–99 con un teclado 一–十 barajado | `roundNumbers()` |
| listen | 听 | audio → carácter (linternas celestes). Solo si el sonido está activado y hay voz china | `roundListen()` |
| dialog (w:2) | 话 | conversación: «¿Qué contestas?», «Completa la frase», «¿Qué significa?» | `roundDialog()` |

Cada ronda se crea con `newRound()`. Define `layout()`, que coloca las piezas usando `area()`, es decir, el hueco libre entre la tarjeta superior y el borde inferior, y `update(t, dt)`. La ronda termina llamando a `resolve(ok, { chino, pinyin, espanol })`. Las transiciones entre rondas son un único barrido continuo de cámara (`transitionOut` → `startRound`), sin saltos.

## Depuración
- `index.html?mode=<clave>` fuerza un modo. `&sub=reply|blank|meaning` fuerza el subtipo de conversación.
- Probar siempre a tamaño móvil (390×844). El sonido solo se activa tras el primer toque, por eso la primera ronda nunca es `listen`.

## Publicar
- Doble clic en `publicar.bat` (git add, commit y push). GitHub Pages se actualiza en 1–2 minutos.
- `.nojekyll` hace que GitHub sirva el HTML tal cual.
- Firma de los commits hechos con Claude: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
