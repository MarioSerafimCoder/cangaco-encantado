# Edição visual segura das primeiras cenas

As grandes formas azuis da Casa de Nilo e da Rua das Cinzas são colisões e gatilhos técnicos. Elas continuam funcionando durante o jogo, mas ficam ocultas e bloqueadas no editor para não cobrirem os sprites nem serem movidas por engano.

## Casa de Nilo

Para mover cama, armário ou bancada, abra:

`Geometry > EditableFurniture`

Selecione o nó-pai `Bed`, `Cabinet` ou `Workbench`. A imagem e a colisão estão agrupadas e se movem juntas.

Para mover prateleiras e luminária, que são apenas decorativas, abra:

`Environment > Architecture > Interior > Furniture`

## Rua das Cinzas

Para mover obstáculos que precisam sustentar o personagem, abra:

`Geometry > EditableObstacles`

Selecione o nó-pai `CarrocaOeste`, `CaixaOeste`, `ToldoCentral`, `CarrocaRampa` ou `CaixaLeste`. Cada nó está agrupado para levar o sprite e sua superfície física juntos.

Os elementos apenas decorativos continuam em:

`Environment > GameplayDecor`

Eles podem ser movidos livremente porque não bloqueiam Nilo.

## Como reconhecer os nós protegidos

- Cadeado: elemento técnico que não deve ser movido isoladamente.
- Olho desligado em `CollisionShape2D`: forma azul oculta apenas no editor; a colisão continua ativa no jogo.
- Grupo: obstáculo composto; mova o nó-pai para manter imagem e colisão alinhadas.
