# Cangaço Encantado

Metroidvania 2D de ação e exploração inspirado no sertão brasileiro e no folclore nordestino. Nilo retorna à Vila do Umbuzeiro depois de um ataque da Companhia do Sol Negro e inicia uma jornada humana de vingança que, pouco a pouco, passa a envolver os Encantados e a restauração do mundo.

Esta entrega é um vertical slice jogável com graybox estilizado. A prioridade continua sendo **gameplay > arquitetura > testabilidade > arte**, agora com uma camada consistente de apresentação e game feel.

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
- Nilo chibi provisório em grade real de 4x4, corrida de quatro frames sincronizada à velocidade e poses próprias por estado.
- Poeira de corrida/pouso, muzzle flash, arco do facão, impacto, cura, recoil visual e micro shake de câmera.
- HUD estilizado com vida, munições, Cabaça, barra de chefe e debug técnico opcional em F3.
- Vila com céu tonal, serras, construções, cercas, chão tratado e landmarks procedurais para Igreja, Praça, Poço e Posto.
- Sprites MVP para Saqueador, Pistoleiro e Zé Tranca, ainda recortados das folhas conceituais com transparência provisória por shader.
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
  tools/                     validação estática local
```

## Material visual

As 15 imagens encontradas no workspace foram copiadas byte a byte para `assets/source/reference/`. O MVP ainda recorta as folhas dos inimigos em runtime e remove o fundo claro com shader. Nilo usa um spritesheet chibi RGBA separado, com grade 4x4 e células de 64x64 px. O personagem é um placeholder visual; a versão narrativa definitiva ainda precisará preservar a identidade de Nilo.

As decisões desta rodada estão resumidas em [Polimento visual e game feel](docs/VISUAL_POLISH.md).

## Validação

No PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate_project.ps1
```

O teste automatizado específico de game feel também pode ser executado com a cena `res://tools/game_feel_validation.tscn`. Ele valida os quatro frames de corrida, o hurtbox agachado e o disparo semiautomático.

As capturas atuais do jogo ficam em [`prints_do_jogo/`](prints_do_jogo/README.md). Depois de mudanças visuais grandes, execute `res://tools/mvp_visual_test.tscn` para sobrescrever os prints oficiais com o estado mais recente da build.

## Roadmap imediato

1. Fazer o primeiro playtest manual completo com teclado e gamepad.
2. Fazer uma rodada de game-feel com controle: aceleração, janela de combo, recoil, hitstop e câmera.
3. Separar salas em cenas individuais com transições e `CameraBounds` próprios.
4. Produzir spritesheets transparentes com grade e pivôs consistentes.
5. Acrescentar Batedor, Incendiário e Jagunço de Preto sobre a mesma base.
6. Evoluir a arena e o balanceamento de Zé Tranca após testes de fluxo.
