# Cangaço Encantado

Metroidvania 2D de ação e exploração inspirado no sertão brasileiro e no folclore nordestino. Nilo retorna à Vila do Umbuzeiro depois de um ataque da Companhia do Sol Negro e inicia uma jornada humana de vingança que, pouco a pouco, passa a envolver os Encantados e a restauração do mundo.

Esta entrega é o vertical slice jogável **0.4.2 — UI/UX Polish** da Área 01 — Vila do Umbuzeiro. A primeira macroárea possui exploração horizontal e vertical, diálogos, loja, economia, colecionáveis, progressão persistente e agora uma camada de interface unificada para teclado e gamepad.

## Stack

- Godot 4.x + GDScript
- resolução interna de 640x360, apresentada em 1920x1080
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
| Abrir diário (mapa, itens, habilidades e amuletos) | M | View/Back |
| Pausar | Esc | Start |
| Mostrar/ocultar debug técnico | F3 | - |
| Liberar a Vila (debug) | F12 | - |

Os scripts de gameplay usam somente ações do `InputMap`; nenhum controle depende de leitura direta de tecla.

## Vertical slice atual

- Treze salas contínuas formam a macroárea: Casa de Nilo, Rua das Cinzas, Vila Baixa, Praça, Igreja, Telhados, Cripta, Subterrâneo, Grutas, Poço, Caverna Rasa, Caverna Profunda e Santuário.
- Nilo possui locomoção chibi com aceleração progressiva até a corrida em cerca de 0,46 s, frenagem rápida, inversão responsiva, salto variável, salto de parede, investida e câmera 640x360 com transições suaves. Espaço/A é exclusivo do salto.
- Combate completo com pistola, rifle, facão, especial, postura, antecipação inimiga, linha de visão e projéteis bloqueados pelo cenário.
- Oito moradores têm diálogo contextual; a Praça funciona como centro seguro e abriga uma loja com cinco itens.
- Moeda, inventário, compras únicas, estados de NPC, diálogos, habilidades, atalhos, colecionáveis e sala atual persistem no save.
- Quatro cordéis e um coração permanente recompensam exploração, rotas altas e retorno com novas habilidades.
- Três checkpoints, atalhos persistentes, caminhos verticais e um diário navegável com mapa, itens, habilidades e amuletos sustentam a estrutura de metroidvania.
- A manifestação no Santuário conclui a Área 01, remove encontros hostis e libera um retorno rápido à Praça e uma saída segura do beta.
- HUD, menu inicial, pausa, configurações, controles, diálogo, loja e Diário usam um Theme central em linguagem pixel art, glyphs adaptativos e componentes reutilizáveis.
- O onboarding ensina uma ação por vez e persiste o aprendizado; moeda, estado da região, objetivo e notificações possuem canais visuais separados.
- Os ambientes usam sprites rasterizados; volumes simples permanecem apenas como colisão invisível, não como arte exibida.
- Sons e música foram deliberadamente adiados para uma etapa futura.

## Estrutura

```text
res://
  assets/source/reference/   material conceitual original, sem modificações
  autoload/                  input, glyphs, notificações, eventos, estado global, mundo e save
  resources/                 parâmetros de player, armas, inimigos e habilidades
  scenes/                    cenas de player, inimigos, boss, mundo e HUD
  scripts/
    combat/                  hitboxes, hurtboxes e projéteis
    components/              vida e postura
    data/                    classes Resource
    player/                  movimento, combate e state machine
    enemies/                 base reutilizável e componentes de IA
    dialogue/                banco e direção de diálogos orientados por dados
    npc/                     moradores e interação contextual
    shop/                    loja, compra e apresentação de mercadorias
    world/                   graybox, salas, checkpoint, atalho e gates
    ui/                      HUD, menus, Diário e componentes de interface
  docs/                      decisões e fontes de design
  tools/                     validação automatizada, capturas e movement lab
```

## Material visual

As imagens de referência permanecem em `assets/source/reference/`. Nilo e os inimigos usam regiões individuais para preservar a baseline e impedir cortes em folhas de espaçamento irregular.

Seis atlas produzidos para a Área 01 foram tratados com transparência e integrados em `assets/area_01/`: interior da Casa de Nilo, elementos de travessia, arquitetura da Vila, Cripta/Subterrâneo, Grutas/Cavernas e UI de diálogo/loja. As folhas originais para tratamento continuam em `assets_para_remover_fundo/area_01_vertical_slice/`.

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

O teste automatizado específico de game feel também pode ser executado com a cena `res://tools/game_feel_validation.tscn`. Ele valida a curva de aceleração de 0,35–0,55 s, sincronização de caminhada/corrida com a velocidade, bob, contatos de pé, virada, fases do salto, pouso, hurtbox agachado, disparo semiautomático, buffer/variante do facão, orientação do projétil, configuração de hitstop e HUD temporário.

O passe de UI/UX possui validação dedicada em `res://tools/ui_ux_polish_validation.tscn`, cobrindo glyphs, onboarding persistente, origem do Diário, layout de diálogo, foco da loja, fila de notificações, compatibilidade de save e componentes do design system.

A estrutura das treze salas de produção é validada por `res://tools/room_production_validation.tscn`. O vertical slice completo é validado por `res://tools/area01_vertical_slice_validation.tscn`, cobrindo fluxo, NPCs, diálogo, loja, economia, colecionáveis, conclusão e persistência. O checklist estético e de gameplay está em [RUA_DAS_CINZAS_TEST_CHECKLIST](docs/RUA_DAS_CINZAS_TEST_CHECKLIST.md).

Para teste manual isolado, abra `res://tools/movement_lab.tscn`. A cena contém pista de corrida, inversão, vão, plataformas e boneco de combate.

As capturas atuais do jogo ficam em [`prints_do_jogo/`](prints_do_jogo/README.md). A revisão da Área 01 é regenerada por `res://tools/area01_visual_review.tscn` em `prints_do_jogo/area_01_vertical_slice/`.

As seis comparações da Rua das Cinzas são atualizadas por `res://tools/rua_das_cinzas_visual_test.tscn`.

As capturas de aceitação da 0.2.4 são geradas por `res://tools/environment_visual_test.tscn`; a comparação de escala de Nilo usa `res://tools/nilo_scale_comparison.tscn`.

## Roadmap imediato

1. Fazer o primeiro playtest manual completo com teclado e gamepad.
2. Ajustar economia, duração e dificuldade com dados de sessões completas.
3. Realizar uma etapa dedicada de música, efeitos sonoros e mixagem.
4. Fazer playtests de acessibilidade e localização com jogadores externos.
5. Congelar a Área 01 como beta e iniciar a pré-produção da Área 02.
