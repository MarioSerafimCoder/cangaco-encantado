# Especificação de spritesheets de Nilo

Esta especificação orienta as próximas folhas. A versão 0.2.6 aceita as folhas irregulares de 1254×1254 px por regiões explícitas, mas novos arquivos devem usar a régua determinística em `docs/sprite_guides/`.

## Formato

- Célula: **256×256 px**.
- Grade básica: **4×4**, folha total de **1024×1024 px**.
- Canal: PNG RGBA, fundo totalmente transparente.
- Direção desenhada: Nilo olhando para a direita; o jogo espelha para a esquerda.
- Área segura: de `(24, 16)` até `(232, 232)`.
- Pivot visual: `(128, 232)`.
- Baseline do pé: `y = 232` dentro da célula.
- Altura-alvo no mundo: aproximadamente **40 px**.
- O último pixel de contato do pé deve fechar com a linha do chão sem sombra embutida.

Chapéu, arma, facão, clarão e poeira devem permanecer dentro da área segura. A sombra de contato é um node separado no Godot e não deve ser desenhada na folha.

## Ordem das animações

| Linha | Estado | Frames | Observação |
|---:|---|---:|---|
| 0 | `IDLE` | 4 | respiração discreta; pés imóveis |
| 1 | `WALK` | 4 | faixa inicial e intermediária da aceleração |
| 2 | `RUN` | 4 | faixa alta da velocidade real, sem espera rígida |
| 3 | `DEATH` | 4 | queda, chão e repouso |

Combate deve ficar em outra folha 4×4, mantendo célula, pivot, direção e baseline: linha 0 para pistola, linha 1 para rifle, linha 2 para facão e linha 3 para ataque especial. Turn, salto, queda, pouso, agachamento e dano podem ocupar folhas adicionais quando receberem arte própria.

## Corrida

Os contatos principais ocorrem nos frames 0 e 2. Nesses frames, o pé plantado deve permanecer na baseline. Frames de passagem elevam discretamente o corpo, sem transformar a corrida em pequenos saltos. O `run_phase` continua sendo a fonte de sincronização para frame, poeira e contato. A troca WALK→RUN ocorre pela velocidade horizontal real e preserva a fase do passo, evitando reinício visível da animação.

## Exceção da folha 0.2.6

As folhas recebidas na 0.2.6 não têm divisões matemáticas uniformes. O controlador registra manualmente região, altura e baseline de cada uma das 32 poses. Isso não deve ser repetido nas próximas gerações: use o PNG transparente de régua para preservar uma grade exata.
