# Iteração 0.2.1 — Fluid Movement & Visual Cohesion

## Resultado

A iteração transforma o vertical slice de uma prova funcional em uma build com resposta visual contínua. O controlador de Nilo mantém a física existente, mas apresenta aceleração, corrida, virada, salto e pouso como um movimento único. O combate ganhou fases explícitas, buffer e congelamentos curtos apenas nos atores envolvidos no impacto.

A Rua das Cinzas continua sendo o primeiro alvo visual de qualidade em paralaxe. Ela combina céu distante, vila ocupada e primeiro plano em camadas rasterizadas independentes. As outras 12 áreas agora também recebem um kit rasterizado próprio de estruturas, ambientes e obstáculos, preservando a geometria e as colisões do graybox.

## Entregas e validação

| Área | Entrega | Como verificar |
|---|---|---|
| Corrida | `run_phase` único, quatro frames, bob e poeira no contato | Correr em `movement_lab.tscn` ou executar `game_feel_validation.tscn` |
| Transições | arrancada, parada e virada | Alternar A/D no laboratório |
| Salto | subida, ápice, queda, fast fall e pouso proporcional | Pular e segurar S durante a queda |
| Facão | antecipação, ativo, continuidade, recuperação e buffer | Apertar J novamente no fim do golpe |
| Impacto | hitstop por golpe, arma e quebra de postura | Acertar o boneco e inimigos |
| Câmera | look-ahead e leitura vertical suave | Correr, inverter direção e cair de uma plataforma |
| HUD | bloco 32% menor e avisos temporários | Entrar em uma sala e aguardar o fade |
| Ambiente | três profundidades rasterizadas na Rua das Cinzas | Percorrer a sala 02 |
| Vila | oito atlas ambientais distribuídos pelas 13 salas | Executar `mvp_visual_test.tscn` e revisar `prints_do_jogo/` |
| Chefe | contorno quente e arena mais legível | Ir à sala 13 ou abrir o print oficial |

## Alvo de qualidade: Rua das Cinzas

Camadas em uso:

1. `rua_sky_far.png` — céu e serras distantes, fator 0,04.
2. `rua_village_mid.png` — casas, ruínas, cercas e ocupação, fator 0,52.
3. `rua_foreground.png` — vegetação, pedras e cercas próximas, fator 1,10.

As imagens-fonte continuam preservadas em `assets/environments/rua_das_cinzas/source/`. As camadas intermediária e frontal agora usam canal alfa RGBA real e não dependem mais de shader de matte.

## Decisões técnicas

- O hitstop não altera `Engine.time_scale`; ele pausa somente os nós participantes e usa temporizador em tempo real.
- A câmera soma look-ahead e shake em offsets separados, evitando acumulação.
- Transformações visuais sempre retornam à posição, escala e rotação-base a cada frame.
- O mundo deixou de executar `queue_redraw()` em intervalos fixos.
- As camadas rasterizadas são ocultadas e deixam de atualizar fora da vizinhança da Rua das Cinzas.
- Os atlas da Vila usam regiões do canvas original; nenhum arquivo corrigido é recortado ou redimensionado no disco.
- A camada de arte reage aos estados `OCCUPIED` e `LIBERATED`, ocultando barricadas e suprimentos exclusivos da ocupação.

## Dívida técnica consciente

- Sprites de Saqueador, Pistoleiro e Zé Tranca ainda são recortes de folhas conceituais.
- As folhas atuais dos três inimigos usam transparência RGBA real e preservam seus canvases originais.
- A geometria de colisão das salas permanece provisória mesmo com a apresentação rasterizada integrada.
- A animação definitiva precisará de spritesheets desenhados para as poses e pivôs já definidos pelo controlador.
- Balanceamento de inimigos e janelas de combo ainda depende de playtest manual com teclado e gamepad.
