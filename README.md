# Cangaço Encantado

Metroidvania 2D de ação e exploração inspirado no sertão brasileiro e no folclore nordestino. Nilo retorna à Vila do Umbuzeiro depois de um ataque da Companhia do Sol Negro e inicia uma jornada humana de vingança que, pouco a pouco, passa a envolver os Encantados e a restauração do mundo.

Esta entrega é a fundação técnica e o primeiro graybox jogável. A prioridade é **gameplay > arquitetura > testabilidade > arte**.

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

O projeto não exige plugins nem dependências externas. O Godot não estava disponível no computador em que o bootstrap foi criado; por isso a estrutura passou por validação estática, mas o primeiro teste de runtime ainda precisa ser feito no editor.

## Controles

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
| Alternar Vila liberada (debug) | F6 | - |

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
    ui/                      HUD de protótipo
  docs/                      decisões e fontes de design
  tools/                     validação estática local
```

## Material visual

As 15 imagens encontradas no workspace foram copiadas byte a byte para `assets/source/reference/`. Elas são folhas conceituais RGB, com fundo incorporado e quadros irregulares; ainda precisam de limpeza e preparação antes de virar spritesheets de produção. O graybox usa placeholders desenhados em GDScript para não misturar arte conceitual com arte pronta.

## Validação

No PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate_project.ps1
```

Depois de abrir no Godot, siga a matriz de testes em `docs/IMPLEMENTATION.md` e corrija qualquer aviso do parser antes de iniciar polimento.

## Roadmap imediato

1. Rodar o projeto no Godot 4.x e ajustar qualquer diferença de versão do parser/API.
2. Fazer uma rodada de game-feel com controle: aceleração, janela de combo, recoil, hitstop e câmera.
3. Separar salas em cenas individuais com transições e `CameraBounds` próprios.
4. Produzir spritesheets transparentes com grade e pivôs consistentes.
5. Acrescentar Batedor, Incendiário e Jagunço de Preto sobre a mesma base.
6. Evoluir a arena e o balanceamento de Zé Tranca após testes de fluxo.

