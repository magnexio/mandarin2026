# Repaso de Chino (mandarin2026)

Web app para repasar vocabulario de mandarín con los compañeros de clase. Todo vive en un único `index.html`, sin backend.
Publicada en GitHub Pages: https://magnexio.github.io/mandarin2026/ (repo `magnexio/mandarin2026`, rama `main`).

## Filosofía (no romperla)
- **Fricción cero:** no hay puntuaciones ni pantalla de inicio. Al abrir la web empieza directamente una ronda aleatoria del último tema elegido (por defecto, «Mezcla»). El único menú es el selector de temas (botón a la izquierda del chip superior).
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
- `VOCAB`: vocabulario `{ espanol, chino, pinyin }`. Los 10 primeros deben ser los números 一 a 十, porque `NUMS = VOCAB.slice(0, 10)`. 零 (`ZERO`), 百 (`BAI`), 第 (`DI`) y 页 (`YE`) también están en `VOCAB`; `numZh(n)` sabe construir 0–999, pero `randNum()` de momento solo saca 0–100 y centenas redondas. Las palabras de la lección 2 llevan `l: 2` (solo como referencia; ningún tema filtra por lección). Puede haber palabras de varios caracteres (爸爸, 男朋友) y pinyin repetido (他/她 = tā): los modos que eligen por sonido o pinyin excluyen distractores con el mismo pinyin.
- `CONFUSABLE`: caracteres parecidos (o que se oyen igual), que se usan como distractores.
- `PHRASES`: frases de conversación como tokens `T(carácter, pinyin)`, para poder dejar huecos (`l: 2` = lección 2, solo como referencia; `voc: true` = puede ir dirigida a alguien). `REPLIES` define qué respuestas son válidas (`ok`) o claramente incorrectas (`bad`) para cada frase; las dudosas no van en ninguna lista, así nunca hay dos correctas. `BLANK_WRONG` da, para cada palabra que puede faltar en «Completa la frase», opciones que nunca forman una frase válida.
- `NAMES` (compañeros de clase) y `KIN` (哥哥, 弟弟): aparecen en «(nombre)，你忙吗？» y similares.
- `MODES`: registro de modos. `w` es el peso (cuántas veces más sale) y `ok()` indica si está disponible.
- `TOPICS`: temas del selector (`mix` Mezcla, `num` Números, `char` Caracteres, `talk` Conversación). Los temas separan por tipo de ejercicio, nunca por lección: siempre entra el vocabulario de todas las lecciones. Cada uno define sus `modes`, el filtro de `vocab` y `phrases`, y los tipos de `pairs`. `vocabPool()` y `topicPhrases()` devuelven lo del tema activo; se guarda en `localStorage`.

## Modos (bucle aleatorio dentro del tema, nunca el mismo dos veces seguidas si hay otro)
| clave | sello | ejercicio | función |
|---|---|---|---|
| tiles | 字 | español → carácter (fichas Mahjong 2×2) | `roundTiles()` |
| pyChar | 拼 | pinyin → carácter | `roundTiles(true)` |
| meaning | 义 | carácter → español (ficha + 4 placas) | `roundMeaning()` |
| orbit | 音 | carácter → pinyin (moneda dorada + linternas en órbita, variantes de tono) | `roundOrbit()` |
| pyNum | 拼 | número 0–100 o centena redonda (200…900) → pinyin (placas, errores típicos) | `roundPlaques()` |
| numbers | 数 | construir el número (0–100 o 200…900) con un teclado 一–十 + 零 百 barajado | `roundNumbers()` |
| page | 页 | número de página: construir 第…页 (teclado con 第 y 页) o elegir su pinyin «dì … yè» | `roundNumbers(true)` / `roundPlaques(true)` |
| listen | 听 | audio → carácter (linternas celestes). Solo si el sonido está activado y hay voz china | `roundListen()` |
| dialog (w:2) | 话 | conversación: «¿Qué contestas?», «Completa la frase», «¿Qué significa?» | `roundDialog()` |
| pairs (w:2) | 配 | parejas: 4 fichas de marfil ↔ 4 placas lacadas. Subtipos (`&sub=`): `zhEs`, `zhPy`, `esPy`, `numZh`, `numPy`, `mix`. Un fallo termina la ronda | `roundPairs()` |

Cada ronda se crea con `newRound()`. Define `layout()`, que coloca las piezas usando `area()`, es decir, el hueco libre entre la tarjeta superior y el borde inferior, y `update(t, dt)`. La ronda termina llamando a `resolve(ok, { chino, pinyin, espanol })`. Las transiciones entre rondas son un único barrido continuo de cámara (`transitionOut` → `startRound`), sin saltos.

## Depuración
- `index.html?mode=<clave>` fuerza un modo y `?topic=mix|num|char|talk` fuerza un tema. `&sub=reply|blank|meaning` fuerza el subtipo de conversación; en `pairs`, `&sub=zhEs|zhPy|esPy|numZh|numPy|mix`.
- Probar siempre a tamaño móvil (390×844). El sonido solo se activa tras el primer toque, por eso la primera ronda nunca es `listen`.

## Publicar
- Doble clic en `publicar.bat` (git add, commit y push). GitHub Pages se actualiza en 1–2 minutos.
- `.nojekyll` hace que GitHub sirva el HTML tal cual.
- Firma de los commits hechos con Claude: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
