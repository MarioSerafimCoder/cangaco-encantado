# Cangaço Encantado

Metroidvania 2D de ação e exploração inspirado no sertão brasileiro e no folclore nordestino. Nilo retorna à Vila do Umbuzeiro depois de um ataque da Companhia do Sol Negro e inicia uma jornada humana de vingança que, pouco a pouco, passa a envolver os Encantados e a restauração do mundo.

Esta entrega é o vertical slice jogável **0.2.6 — Nilo Animation Upgrade**. Nilo recebeu novas folhas chibi de locomoção e combate, idle com respiração e piscada, caminhada própria e corrida automática após dois segundos de movimento contínuo.

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
| Andar/correr após 2 s | A/D ou setas | Analógico esquerdo |
| Mirar verticalmente | Shift + W/S | LT + analógico |
| Pular | Espaço | A |
| Agachar | Ctrl | Clique do analógico esquerdo |
| Facão | J | X |
| Pistola | K | RT |
| Rifle | L | RB |
| Ataque especial | I | LB |
| Curar | Q | B |
| Interagir | E | Y |
| Pausar | Esc | Start |
| Mostrar/ocultar debug técnico | F3 | - |
| Liberar a Vila (debug) | F12 | - |

Os scripts de gameplay usam somente ações do `InputMap`; nenhum controle depende de leitura direta de tecla.

## Vertical slice atual

- Nilo com aceleração/desaceleração, salto variável, coyote time, jump buffer, fast fall e agachamento.
- Vida de 5 HP, dano, knockback, hurt lock, invulnerabilidade, morte e retorno ao checkpoint.
- Pistola semiautomática de 8 tiros, recarga automática e munição global infinita.
- Rifle de 4 tiros, longo alcance, recuo controlado e alto dano de postura.
- Ataque especial amplo e poderoso com recarga própria de 5 segundos.
- Facão com combo de 3 golpes, corte para cima, corte descendente e bounce ao acertar.
- Cabaça de Água com 2 cargas, cura de 2 HP, uso de 1,1 s e interrupção por dano.
- Componentes reutilizáveis de vida, postura, hurtbox, hitbox, detecção, movimento e state machine.
- Saqueador melee e Pistoleiro ranged funcionais em graybox.
- Arquitetura inicial de Zé Tranca com tiro direto, tiro baixo, coronhada, reposicionamento, rajada e duas intensidades.
- Nilo chibi com regiões individuais, respiração, piscada, quatro poses de caminhada, quatro de corrida e transição automática após 2 segundos.
- Facão faseado com buffer, hitstop localizado, cortes direcionais, finalizador visual, projéteis orientados e feedbacks distintos de cura.
- Câmera com look-ahead suave e leitura vertical de quedas.
- HUD compacto com vida, munições, Cabaça, barra de chefe, avisos temporários e debug técnico opcional em F3.
- Rua das Cinzas com três camadas rasterizadas independentes e paralaxe real.
- Rua das Cinzas em cena própria, com baseline física/visual, entradas, spawns, camera bounds e composição editável.
- Telhados da Vila, Praça do Umbu, Barracos Queimados, Posto de Comando e Arena de Zé Tranca também usam cenas ambientais próprias, com arquitetura completa, paralaxe contínuo e chão em camadas.
- Escala visual de Nilo normalizada por altura útil medida entre idle, corrida, pistola, rifle, facão e especial, sem multiplicador fixo de ataque.
- Sombras de contato pixeladas para Nilo, Saqueador, Pistoleiro e Zé Tranca.
- Vila com céu tonal, serras e um kit rasterizado de ambientes, estruturas e obstáculos cobrindo as 13 áreas.
- Sprites MVP para Saqueador, Pistoleiro e Zé Tranca com transparência PNG RGBA real, regiões individuais sem cortes e baseline estável entre estados.
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

As 15 imagens encontradas no workspace foram copiadas byte a byte para `assets/source/reference/`. Saqueador, Pistoleiro, Zé Tranca e as camadas rasterizadas da Rua das Cinzas usam transparência RGBA real. Nilo usa duas folhas chibi RGBA de 1254×1254 px, recortadas por regiões individuais porque o espaçamento gerado não é uniforme.

Os oito atlas ambientais corrigidos usam transparência RGBA real e estão integrados em `assets/environments/vila_umbuzeiro/atlases/`. O kit complementar 0.2.5 está em `assets/environments/vila_umbuzeiro/generated_0_2_5/` e substitui os fundos, chãos, moradores e interativos provisórios nas salas restantes.

O kit visual 0.2.3 permanece arquivado em `imagens_para_remover_fundo_0_2_3/`, junto do registro de prompts. As cinco folhas corrigidas já estão integradas ao runtime: molduras da HUD, preenchimentos e transições da Rua das Cinzas, fogo/fumaça animados e as poses dedicadas de revólver e espingarda de Nilo.

O histórico da base está em [Iteração 0.2.1](docs/ITERATION_0_2_1.md), e as mudanças atuais estão no [changelog](CHANGELOG.md).

O padrão para converter as próximas salas está em [Pipeline de produção](docs/ROOM_PRODUCTION_PIPELINE.md). Novas folhas de personagem devem seguir [NILO_ANIMATION_SPEC](docs/NILO_ANIMATION_SPEC.md) e a régua em `docs/sprite_guides/`.

O resultado técnico da sala-base está em [Iteração 0.2.2](docs/ITERATION_0_2_2.md), a integração dos novos atlas em [Iteração 0.2.3](docs/ITERATION_0_2_3.md), o passe ambiental em [Iteração 0.2.4](docs/ITERATION_0_2_4.md), a correção dos recortes em [Iteração 0.2.5](docs/ITERATION_0_2_5.md) e a nova animação do herói em [Iteração 0.2.6](docs/ITERATION_0_2_6.md).

## Validação

No PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate_project.ps1
```

O teste automatizado específico de game feel também pode ser executado com a cena `res://tools/game_feel_validation.tscn`. Ele valida fase da corrida, bob, contatos de pé, virada, fases do salto, pouso, hurtbox agachado, disparo semiautomático, buffer/variante do facão, orientação do projétil, configuração de hitstop e HUD temporário.

A estrutura das treze salas de produção é validada por `res://tools/room_production_validation.tscn`. O teste cobre identidade, bounds, entradas, spawns, chão, baseline, paralaxe, colisões, estados visuais, perfil de nitidez e transições da câmera central. O checklist estético e de gameplay está em [RUA_DAS_CINZAS_TEST_CHECKLIST](docs/RUA_DAS_CINZAS_TEST_CHECKLIST.md).

Para teste manual isolado, abra `res://tools/movement_lab.tscn`. A cena contém pista de corrida, inversão, vão, plataformas e boneco de combate.

As capturas atuais do jogo ficam em [`prints_do_jogo/`](prints_do_jogo/README.md). Depois de mudanças visuais grandes, execute `res://tools/mvp_visual_test.tscn` para sobrescrever os prints oficiais com o estado mais recente da build.

As seis comparações da Rua das Cinzas são atualizadas por `res://tools/rua_das_cinzas_visual_test.tscn`.

As capturas de aceitação da 0.2.4 são geradas por `res://tools/environment_visual_test.tscn`; a comparação de escala de Nilo usa `res://tools/nilo_scale_comparison.tscn`.

## Roadmap imediato

1. Fazer o primeiro playtest manual completo com teclado e gamepad.
2. Fazer uma rodada de game-feel com controle: aceleração, janela de combo, recoil, hitstop e câmera.
3. Separar salas em cenas individuais com transições e `CameraBounds` próprios.
4. Produzir spritesheets transparentes com grade e pivôs consistentes.
5. Acrescentar Batedor, Incendiário e Jagunço de Preto sobre a mesma base.
6. Evoluir a arena e o balanceamento de Zé Tranca após testes de fluxo.
