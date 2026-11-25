# Repaso de Chino (mandarin2026)

Web app para repasar vocabulario de mandarín con los compañeros de clase. Todo vive en un único `index.html`, sin backend.
Publicada en GitHub Pages: https://magnexio.github.io/mandarin2026/ (repo `magnexio/mandarin2026`, rama `main`).

## Filosofía (no romperla)
- **Fricción cero:** no hay puntuaciones. Al abrir la web solo hay un sello 开始 («Toca para empezar»): ese toque desbloquea la voz y los sonidos (iOS lo exige) y empieza una ronda aleatoria con lo último elegido (por defecto, «Todo» + «Mezcla»). El único menú es el selector (botón a la izquierda del chip): «Por lecciones», «Por temas» (en cada uno sale de todo: no se elige tipo de ejercicio, lo pidió el usuario), el interruptor «Pinyin de ayuda» y, al final (no al principio, lo pidió el usuario), «Escritura» con el botón del pincel «Practicar la escritura». Desde la escritura, el botón grande dice «Volver a repasar». Los cambios se aplican al cerrar el menú («Jugar» o tocar fuera).
- Si aciertas, explosión de partículas y pasas a la siguiente ronda. Si fallas, una tarjeta muestra la respuesta (carácter + pinyin coloreado por tono + español), lo que tocaste tachado y por qué no era eso (4,2 s, o 6 s si hay explicación). Toque corto: seguir; mantener pulsado: congelarla para leer; 🔊 de la tarjeta: repetir despacio.
- Lo que fallas vuelve 2-4 rondas después en otro tipo de ejercicio, con el sello rojo 复 (repaso).
- Pensada para el móvil: abrir, jugar un minuto y cerrar.
- Estética china tradicional: fondo granate oscuro, luz cálida de linternas, dorados, fichas Mahjong.
- La interfaz está en español. El usuario aprende chino en clase, con compañeros (véase `NAMES`).

## Stack
- three.js 0.160 (ES modules vía importmap desde jsDelivr), con postproceso: bloom (UnrealBloomPass) + OutputPass con tono ACES.
- GSAP 3.12.5 (cdnjs) para todas las animaciones.
- Web Speech API para pronunciar en chino (`zh-CN`). Si una frase empieza por un nombre latino («Lorea，你好吗？»), el nombre se lee con voz `es-ES` y el resto en chino.
- SFX sintetizados con Web Audio (escala pentatónica).
- Fuentes de Google: Noto Sans SC (caracteres), Noto Sans (pinyin y títulos), Inter (interfaz). Letra sencilla tipo Arial/heiti a propósito: el usuario no quiere tipografías caligráficas (cuesta leer).
- El texto de los objetos 3D se dibuja con Canvas 2D a texturas de 512–1024 px (`layoutGlyph` centra según la caja real del glifo).
- Fichas con pinyin debajo (`makeTile(ch, R, py)`) solo en los ejercicios de estructura: construir frases, completar la frase y teclados de números/páginas/dictado. Nunca donde el objetivo es reconocer el carácter (tiles, pyChar, meaning, orbit, listen, pairs), porque daría la respuesta. Con «Pinyin de ayuda» apagado (`pyOn = false`, localStorage `pinyin`) no hay pinyin en fichas (`makeTile`), burbujas (`bubble`), placas de respuesta ni escritura, y no salen los modos de pinyin (pyChar, orbit, pyNum, página→pinyin, parejas con pinyin). La tarjeta de la respuesta sí lo muestra siempre.

## Dónde tocar en `index.html`
- `VOCAB`: vocabulario `{ espanol, chino, pinyin }`. Los 10 primeros deben ser los números 一 a 十, porque `NUMS = VOCAB.slice(0, 10)`. 零 (`ZERO`), 百 (`BAI`), 第 (`DI`) y 页 (`YE`) también están en `VOCAB`; `numZh(n)` sabe construir 0–999, pero `randNum()` de momento solo saca 0–100 y centenas redondas. Cada palabra lleva la lección donde apareció por primera vez: `l: 2`…`l: 4` (sin `l` = lección 1). El 2026-11-17 se juntaron las antiguas lecciones 1 y 2 y las demás bajaron un número (localStorage `lessons` = '4' marca la migración). Lección 1: 力 门 也 马 女 木 火 人 林, números 0-100 y centenas, 我 你 好 很, 丁 刀 又 大 口 土 尼 不 可 吗 呢 妈妈 哥哥, 你忙吗/你要咖啡吗 y 第…页. Lección 2: 是 哪 国 那 谁 老师 中国 中国人 西班牙 巴斯克 您 y las bebidas (白酒 = «vino blanco», como en clase). Lección 3: 这 外语 医生 奶奶 外婆 生日, países (英国 = «Reino Unido»), idiomas (país + 语/文; solo formas correctas: 汉语/中文, 英语, 日语…) y los caracteres 匕 中 日 贝 王 玉 矢 生 者 们 老 师 医 (significados como en la lista de clase: 匕 «Puñal», 老 «Mayor», 师 «Sabio, maestro»…). Lección 4: 认识 高兴 高 可以 进来/进 来 请 记者 请问 问 贵姓 姓 叫 先生 行 不行 y sus frases (pedir permiso, 请问您贵姓, 认识你很高兴; 不行 para decir «no puedes», no 不可以); 2.ª parte: caracteres para escribir 小 心 水 月 手 田 白 只 言, 非常/超级 (我非常不好, 我超级好), 加油, meses (一月…十二月), fechas (mes + 月 + día + 日 o 号), 星期一…星期六 y domingo 星期日/星期天, 什么, 学习, 学生, 语言, 学院, 大学, 医院, 加拿大, 马大为 (estudiante estadounidense del libro, solo en frases) y 的 (我妈妈的朋友, 语言学院的学生); repaso: 岁 (我二十五岁: número + 岁, sin 是), 你贵姓？ → 我姓马，叫马大为, 你是学生吗？ → 我是汉语学生, 很高兴认识你 → 我也很高兴认识你, y para escribir 认 识 语 汉 您 朋 友 贵 姓 叫 的 (los que no son palabra sueltas van en `WRITE_EXTRA`). `syn`: palabras con el mismo significado (汉语/中文, 师/老师…) que nunca salen juntas como opciones. `c: true` (lista `WRITE_CHARS`): caracteres que se aprenden a escribir → tema «Caracteres». Puede haber palabras de varios caracteres (爸爸, 男朋友) y pinyin repetido (他/她 = tā): los modos que eligen por sonido o pinyin excluyen distractores con el mismo pinyin.
- `CONFUSABLE`: caracteres parecidos (o que se oyen igual), que se usan como distractores.
- `PHRASES`: frases de conversación como tokens `T(carácter, pinyin)`, para poder dejar huecos (`l` = lección; `voc: true` = puede ir dirigida a alguien; `alts` = otros órdenes válidos para «Ordena la frase», p. ej. 很高兴认识你). Hay frases inventadas (comentario «Inventadas con lo que ya se sabe»): solo con vocabulario ya visto en clase y `l` = la lección más alta de sus palabras; cada frase va en alguna temática. `REPLIES` define qué respuestas son válidas (`ok`) o claramente incorrectas (`bad`) para cada frase; las dudosas no van en ninguna lista, así nunca hay dos correctas. `BLANK_WRONG` da, para cada palabra que puede faltar en «Completa la frase», opciones que nunca forman una frase válida.
- `NAMES` (compañeros de clase) y `KIN` (哥哥, 弟弟): aparecen en «(nombre)，你忙吗？» y similares.
- `MODES`: registro de modos. `w` es el peso (cuántas veces más sale) y `ok()` indica si está disponible.
- Aprendizaje (sección «APRENDIZAJE»): `pyHTML` colorea el pinyin por tono (solo en respuestas); `explainPick`, `toneWhy`, `numberWhy`, `replyWhy`, `orderWhy`, `HINTS` (pares que se confunden) y `WORD_RULE` generan la explicación del fallo, que se pasa como `resolve(false, ans, { picked, why })`. Nunca deben enseñar algo falso.
- `Mem` (localStorage `mem:v1`): repetición espaciada por palabra/frase/número (`memKey`), cajas 0-5; `wpick` sortea dando más peso a lo que toca repasar. `Echo`: cola de fallos que vuelven en otro modo (`ECHO_MODES`, `echoFits`, consumo con `Echo.peek` en `pickTarget`, diálogo, `roundOrder` y `forcedNum`). Si localStorage falla, todo sigue al azar.
- Menú = contenido × ejercicio. `TOPICS` es el ejercicio: en el menú siempre `mix` (`words` Palabras y `talk` Frases solo con `?topic=` para depurar; `write` Escritura va aparte, con su botón al final del menú, y no usa el contenido). `contentKey` es lo elegido en «Por lecciones» o «Por temas»: `all`, una lección `1`-`4` (campo `l`) o una temática de `THEMES` (`hola` Saludar, `mang` Estar ocupado, `nums` Números, `beber` Bebidas, `pais` Países, `quien` ¿Quién es?, `nombre` Presentarse, `permiso` Pedir permiso, `chars` Caracteres (`c: true`), `fecha` Fechas (`dates`: activa el modo date), `xue` Estudiar). «Todo» va aparte, arriba del todo (no dentro de «Por lecciones»): todas las lecciones y temas. Cada temática lista sus caracteres (`vocab`) y sus ids de frases (`phrases`); al añadir materia nueva, meterla también en su temática. Números 0-100 = lección 1 o temática Números; páginas = lección 1 o Números (`numsIn`, `pagesIn`). `vocabIn`/`phraseIn`, `modeFits`, `modesFor(ejercicio, contenido)`: el contenido sale desactivado si no tiene material ni con Mezcla; si el ejercicio no encaja con el contenido elegido, pasa a Mezcla. Se guarda en localStorage (`topic`, `ex`, `content`, `pinyin`); los antiguos temas `num`/`char` se migran a Palabras + Números/Caracteres.

## Modos (bucle aleatorio dentro del tema, nunca el mismo dos veces seguidas si hay otro)
| clave | sello | ejercicio | función |
|---|---|---|---|
| tiles | 字 | español → carácter (fichas Mahjong 2×2) | `roundTiles()` |
| pyChar | 拼 | pinyin → carácter | `roundTiles(true)` |
| meaning | 义 | carácter → español (ficha + 4 placas) | `roundMeaning()` |
| orbit | 音 | carácter → pinyin (moneda dorada + linternas en órbita, variantes de tono) | `roundOrbit()` |
| pyNum | 拼 | número 0–100 o centena redonda (200…900) → pinyin (placas, errores típicos) | `roundPlaques()` |
| numbers | 数 | construir el número (0–100 o 200…900) con un teclado 一–十 + 零 百 barajado | `roundNumbers()` |
| page | 页 | número de página: construir 第…页 (teclado con 第 y 页) o elegir su pinyin «dì … yè» | `roundNumbers({ page: true })` / `roundPlaques(true)` |
| dictation | 听 | dictado: la voz dice un número o una página despacio (`DICTATE_RATE`) y se construye de oído. Solo con voz | `roundNumbers({ audio: true })` |
| order (w:2) | 句 | ordenar las fichas de una frase de clase (+1 ficha trampa); a veces solo de oído. Acepta 爸爸、妈妈 en los dos órdenes | `roundOrder()` |
| read | 读 | «Lee y entiende»: una frase en caracteres para entenderla de cabeza, sin respuesta. Botones «Ver pinyin» (y lo dice en voz alta) y «Ver significado» (destapa también el pinyin); «Siguiente» llama a `resolve(true, …, { noMem, quiet })` (quiet = sin sonido de acierto) | `roundRead()` |
| listen | 听 | audio → carácter (linternas celestes). Solo si el sonido está activado y hay voz china | `roundListen()` |
| dialog (w:2) | 话 | conversación: «¿Qué contestas?», «Completa la frase», «¿Qué significa?» | `roundDialog()` |
| write (solo) | 写 | escritura: orden de trazos con Hanzi Writer (jsDelivr) — 1) ver trazo a trazo, 2) calcar sobre la silueta, 3) de memoria (pista tras 3 fallos). Solo con el botón «Practicar la escritura» del final del menú (`solo: true`, nunca en Mezcla). Caracteres en `WRITE_LESSONS`; la escritura NO filtra por lección (`writePool` = todos, al azar), lo pidió el usuario; trazos guardados en `trazos/<carácter>.json` (licencia `trazos/ARPHICPL.TXT`) | `roundWrite()` |
| date | 月 | fechas (lección 4 o tema Fechas, `datesIn`): construir un mes (三月), una fecha (三月十五日/号) o un día de la semana (星期三; domingo vale 星期日 o 星期天, `live` guarda las secuencias aún posibles) con un teclado de 12 fichas; a veces de oído. Sin memoria ni eco | `roundNumbers({ date: 'month'\|'day'\|'week' })`, `dateTask` |
| comp | 部 | partes del carácter: con el significado (y el pinyin si está activado) se eligen las dos piezas que forman el carácter (他 = 亻 + 也, 国 = 囗 + 玉…), en cualquier orden, con un teclado de 6 piezas (radicales con su nombre: 亻 persona, 讠 palabra, 氵 agua…). Datos en `COMP` (el significado no lleva caracteres: daría la respuesta), `COMP_NAMES`, `COMP_PY`; sale si el contenido tiene alguna palabra con ese carácter (`compPool`) | `roundNumbers({ comp: true })`, `compTask` |
| pairs (w:2) | 配 | parejas: 4 fichas de marfil ↔ 4 placas lacadas. Subtipos (`&sub=`): `zhEs`, `zhPy`, `esPy`, `numZh`, `numPy`, `mix`. Un fallo termina la ronda | `roundPairs()` |

Cada ronda se crea con `newRound()`. Define `layout()`, que coloca las piezas usando `area()`, es decir, el hueco libre entre la tarjeta superior y el borde inferior, y `update(t, dt)`. La ronda termina llamando a `resolve(ok, { chino, pinyin, espanol })`. Las transiciones entre rondas son un único barrido continuo de cámara (`transitionOut` → `startRound`), sin saltos.

## Rendimiento (móvil): no deshacer
- `OutputPass.needsSwap = false` (un solo RT MSAA), bloom sumado en el shader del OutputPass (`bloom.fused`), RT del bloom y canvas sin profundidad, `__ignoreDepthValues` en cada render.
- `canvasTexture` encoge el lienzo tras subirlo (`onUpdate`) y guarda `userData.redraw` para `webglcontextrestored`. Nunca poner `needsUpdate` a una textura ya subida.
- `texCache` = `{ t, used }` con presupuesto (`trimTex`) solo para `coin:`, `plq:`, `card:` y `py:` fuera del vocabulario.
- Precalentado con `setRenderTarget(composer.readBuffer)` y sin liberar los materiales de muestra; precarga en ratos quietos (`warmList`) con las mismas claves que las rondas.
- Piezas doradas fusionadas (`mergeGeo`). En segundo plano se liberan los RT del postproceso.
- Al acertar: «chiklink», la propia pieza se tiñe de verde (`glowFace` → `tintPiece`) y explosión verde y blanca (`OK_SPARKS`), sin cartel. Al fallar: sin sonido, destello rojo y la pieza elegida se tiñe de rojo (`rejectTile`); la correcta NO se marca (ya la enseña la tarjeta). Trasera de las fichas: azul.

## Depuración
- `?perf`: FPS, ms, draw calls y el peor fotograma de cada ronda; `__bench(n, pr)` mide n renders; `__ab(a, b)` compara dos configuraciones píxel a píxel; `__dbg` expone renderer/composer/round.
- `index.html?mode=<clave>` fuerza un modo, `?topic=mix|words|talk|write` el ejercicio, `?content=all|1…4|hola|mang|nums|…` el contenido (`?lesson=` también vale) y `?pinyin=0` quita el pinyin de ayuda. Con `?perf`, `__dbg.cfg` permite recorrer combinaciones (`set(ejercicio, contenido, pinyin)`, `modesFor`, `MODES`…). `&sub=reply|blank|meaning` fuerza el subtipo de conversación; en `pairs`, `&sub=zhEs|zhPy|esPy|numZh|numPy|mix`.
- Probar siempre a tamaño móvil (390×844). El sonido se activa con el toque del sello 开始. En el altavoz, toque = repetir y mantener = repetir despacio (`holdToSlow`).
- Al probar en el panel del navegador (oculto), `gsap.ticker.lagSmoothing(0)` hace que las animaciones avancen en tiempo real.

## Publicar
- Doble clic en `publicar.bat` (git add, commit y push). GitHub Pages se actualiza en 1–2 minutos.
- `.nojekyll` hace que GitHub sirva el HTML tal cual.
- Firma de los commits hechos con Claude: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
