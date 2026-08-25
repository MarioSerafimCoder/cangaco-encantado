# Cangaço Encantado

Metroidvania 2D de ação e exploração inspirado no sertão brasileiro e no folclore nordestino. Nilo retorna à Vila do Umbuzeiro depois de um ataque da Companhia do Sol Negro e inicia uma jornada humana de vingança que, pouco a pouco, passa a envolver os Encantados e a restauração do mundo.

Esta entrega é o vertical slice jogável **0.2.1 — Fluid Movement & Visual Cohesion**. A prioridade continua sendo **gameplay > arquitetura > testabilidade > arte**, agora com movimento contínuo, combate faseado e a Rua das Cinzas como primeiro alvo visual de qualidade.

## Stack

- Godot 4.x + GDScript
- resolução interna de 320x180
- renderização pixel-perfect, filtro nearest e snap de transform/vértice
- teclado e gamepad
- Windows/Steam como alvo inicial
- Git + GitHub

## Como abrir

1. Instale ou use uma versão portátil do Godot 4.x em um computador onde isso seja permitido.
2. Abra o Godot Project Manager.
3. Importe o arquivo `project.godot` desta pasta.
4. Execute a cena principal com **F6/F5**.

O projeto não exige plugins nem dependências externas. Ele foi importado e inicializado com sucesso no Godot 4.7.1 estável: todos os scripts foram compilados e a cena principal completou um smoke test headless de 180 frames sem erros.

## Controles

Consulte também o [manual detalhado de teclado](docs/CONTROLS.md).

| Ação | Teclado | Gamepad |
|---|---|---|
| Mover | A/D ou setas | Analógico esquerdo |
| Mirar verticalmente | Shift + W/S | LT + analógico |
| Pular | Espaço | A |
| Agachar | Ctrl | Clique do analógico esquerdo |
| Facão | J | X |
| Revólver | K | RT |
| Espingarda | L | RB |
| Curar | Q | B |
| Interagir | E | Y |
| Pausar | Esc | Start |
| Mostrar/ocultar debug técnico | F3 | - |
| Liberar a Vila (debug) | F12 | - |

Os scripts de gameplay usam somente ações do `InputMap`; nenhum controle depende de leitura direta de tecla.

## Vertical slice atual

- Nilo com aceleração/desaceleração, salto variável, coyote time, jump buffer, fast fall e agachamento.
- Vida de 5 HP, dano, knockback, hurt lock, invulnerabilidade, morte e retorno ao checkpoint.
- Revólver de 6 tiros, recarga automática e munição global infinita.
- Espingarda de 2 tiros, dispersão curta, recuo e alto dano de postura.
- Facão com combo de 3 golpes, corte para cima, corte descendente e bounce ao acertar.
- Cabaça de Água com 2 cargas, cura de 2 HP, uso de 1,1 s e interrupção por dano.
- Componentes reutilizáveis de vida, postura, hurtbox, hitbox, detecção, movimento e state machine.
- Saqueador melee e Pistoleiro ranged funcionais em graybox.
- Arquitetura inicial de Zé Tranca com tiro direto, tiro baixo, coronhada, reposicionamento, rajada e duas intensidades.
- Nilo chibi provisório em grade real de 4x4, `run_phase` contínuo, contatos de pé e transições de movimento.
- Facão faseado com buffer, hitstop localizado, cortes direcionais, projéteis orientados e feedbacks distintos de cura.
- Câmera com look-ahead suave e leitura vertical de quedas.
- HUD compacto com vida, munições, Cabaça, barra de chefe, avisos temporários e debug técnico opcional em F3.
- Rua das Cinzas com três camadas rasterizadas independentes e paralaxe real.
- Vila com céu tonal, serras e um kit rasterizado de ambientes, estruturas e obstáculos cobrindo as 13 áreas.
- Sprites MVP para Saqueador, Pistoleiro e Zé Tranca com transparência PNG RGBA real, sem shader de recorte de fundo.
- As 13 áreas da Vila do Umbuzeiro em um percurso contínuo de graybox.
- Checkpoint na Igreja Velha, atalho Armazém-Praça, Poço parcialmente bloqueado e saída para Pedra Seca.
- Estados `OCCUPIED` e `LIBERATED`, com incêndios/inimigos/barricadas e retorno seguro da Vila.
- Save JSON em `user://cangaco_encantado_save.json` para checkpoint, vida, cura, boss, atalhos, habilidades e flags do mundo.

## Estrutura

```text
res://
  assets/source/reference/   material conceitual original, sem modificações
  autoload/                  input, eventos, estado global, mundo e save
  resources/                 parâmetros de player, armas, inimigos e habilidades
  scenes/                    cenas de player, inimigos, boss, mundo e HUD
  scripts/
    combat/                  hitboxes, hurtboxes e projéteis
    components/              vida e postura
    data/                    classes Resource
    player/                  movimento, combate e state machine
    enemies/                 base reutilizável e componentes de IA
    bosses/                  comportamento de Zé Tranca
    world/                   graybox, salas, checkpoint, atalho e gates
    ui/                      HUD de jogo e camada de debug opcional
  docs/                      decisões e fontes de design
  tools/                     validação automatizada, capturas e movement lab
```

## Material visual

As 15 imagens encontradas no workspace foram copiadas byte a byte para `assets/source/reference/`. Saqueador, Pistoleiro, Zé Tranca e as camadas rasterizadas da Rua das Cinzas usam transparência RGBA real. Nilo usa um spritesheet chibi RGBA separado, com grade 4x4 e células de 64x64 px.

Os oito atlas ambientais corrigidos também usam transparência RGBA real e estão integrados em `assets/environments/vila_umbuzeiro/atlases/`. Eles fornecem fachadas, landmarks, plataformas visuais, obstáculos e adereços para todas as 13 salas sem alterar a geometria de colisão do graybox.

As decisões desta rodada estão resumidas em [Iteração 0.2.1](docs/ITERATION_0_2_1.md) e no [changelog](CHANGELOG.md).

## Validação

No PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate_project.ps1
```

O teste automatizado específico de game feel também pode ser executado com a cena `res://tools/game_feel_validation.tscn`. Ele valida fase da corrida, bob, contatos de pé, virada, fases do salto, pouso, hurtbox agachado, disparo semiautomático, buffer/variante do facão, orientação do projétil, configuração de hitstop e HUD temporário.

Para teste manual isolado, abra `res://tools/movement_lab.tscn`. A cena contém pista de corrida, inversão, vão, plataformas e boneco de combate.

As capturas atuais do jogo ficam em [`prints_do_jogo/`](prints_do_jogo/README.md). Depois de mudanças visuais grandes, execute `res://tools/mvp_visual_test.tscn` para sobrescrever os prints oficiais com o estado mais recente da build.

## Roadmap imediato

1. Fazer o primeiro playtest manual completo com teclado e gamepad.
2. Fazer uma rodada de game-feel com controle: aceleração, janela de combo, recoil, hitstop e câmera.
3. Separar salas em cenas individuais com transições e `CameraBounds` próprios.
4. Produzir spritesheets transparentes com grade e pivôs consistentes.
5. Acrescentar Batedor, Incendiário e Jagunço de Preto sobre a mesma base.
6. Evoluir a arena e o balanceamento de Zé Tranca após testes de fluxo.
