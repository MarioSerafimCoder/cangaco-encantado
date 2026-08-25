# Guia de composição ambiental

## Pergunta inicial

Antes de posicionar qualquer sprite, definir o lugar: função, construção, circulação, entradas e relação com as salas vizinhas. Uma plataforma só existe quando sua estrutura visual explica por que Nilo pode pisar nela.

## Arquitetura

- Telhado implica fachada, parede, fundação e rua.
- Sacada implica vigas, coluna ou parede que sustente o volume.
- Ruína precisa mostrar continuidade entre a parte preservada, a ruptura e os escombros no chão.
- Assets cuja forma sugere continuação não devem aparecer isolados. Completar com parede, suporte, transição ou outro trecho arquitetônico.
- Portas, janelas e caminhos devem indicar como moradores usariam o espaço.

## Continuidade

- Compartilhar horizonte, céu, névoa, serras, luz e família de cores entre salas adjacentes.
- Bordas usam paredes, becos, vegetação, portões ou ruínas para evitar corte abrupto.
- Alterações locais de paleta devem expressar função: praça mais clara, barracos carbonizados, posto militar vermelho, arena fortificada.

## Background e paralaxe

Ordem de referência:

```text
-100 céu
 -80 serras e névoa
 -50 cidade distante
 -20 arquitetura local
   0 solo e gameplay
  10 personagens
  20 props de gameplay
  30 foreground
  40 VFX
```

Salas migradas usam `CameraParallaxLayer` e nunca dependem das montanhas poligonais do graybox. A continuidade mínima é céu → névoa → serras → cidade → arquitetura local.

## Ground visual system

O topo físico permanece simples, normalmente em `y=150`. O visual é separado em:

1. `Surface`: terra, pedra ou piso que recebe os pés.
2. `Edge`: irregularidade, pedras, raízes ou erosão.
3. `Body`: massa inferior do solo.
4. `Detail`: rachaduras, manchas, cinza e detritos.

Fachadas e objetos grandes precisam de fundação, detrito ou sombra de contato na união com o solo. Evitar bloco marrom uniforme ocupando toda a parte inferior.

## Foreground

- Usar para enquadrar, criar profundidade e esconder apenas bordas não jogáveis.
- Não cobrir Nilo, inimigos, projéteis, chão de aterrissagem ou centro de uma arena.
- Poucos elementos grandes são preferíveis a dezenas de props pequenos.

## Crop e padding

- Distinguir crop acidental de elemento estrutural incompleto.
- Crop acidental: ampliar região para preservar outline, sombra e pontas.
- Estrutura incompleta: adicionar suporte ou continuação; não ampliar um vazio do atlas.
- Conferir o resultado em 320×180 com HUD e câmera reais.

## Baseline e plataformas

- Baseline principal da Vila: `y=150`.
- O topo visual e o topo do `CollisionShape2D` usam o mesmo `y` inteiro.
- Telhados jogáveis possuem fachada visível até a rua.
- Props de background não recebem colisão.
- F3 deve permitir conferir room bounds, entradas, spawns e shapes.

## Occupied e liberated

`room_occupied_only` contém bandeiras da Companhia, fogo, fumaça, barricadas e peso cromático. `room_liberated_only` remove esses elementos e introduz sinais discretos de retorno, sem restaurar instantaneamente os danos da guerra.

## Checklist de lógica arquitetônica

Antes de aprovar a sala, responder:

1. O que é este lugar?
2. Onde está a rua?
3. Onde estão casas e entradas?
4. O que sustenta cada plataforma?
5. Por que Nilo pode pisar ali?
6. Como a composição continua nas duas bordas?
7. O foreground deixa o gameplay legível?
8. Occupied e liberated contam estados diferentes sem trocar de cidade?

Se uma resposta for apenas “porque é uma plataforma”, a sala ainda não está pronta.
