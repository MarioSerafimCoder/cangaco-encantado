# Pipeline de produção de salas

Este documento define o padrão inaugurado pela Rua das Cinzas na versão 0.2.2. A cena de referência é `res://scenes/world/vila_umbuzeiro/rooms/rua_das_cinzas.tscn`.

O princípio central é que a cena visual, a geometria física e o gameplay sejam editados no mesmo espaço. Scripts coordenam estado e comportamento; não funcionam como editor de layout.

## Estrutura mínima

```text
RoomName (RoomController)
├── Environment
│   ├── Sky
│   ├── FarBackground
│   ├── MidBackground
│   ├── GameplayDecor
│   ├── OccupiedOnly
│   ├── LiberatedOnly
│   └── Foreground
├── Geometry
│   ├── Ground
│   ├── Platforms
│   └── Walls
├── Gameplay
│   ├── Entrances
│   ├── Actors
│   ├── EnemySpawns
│   ├── Interactables
│   └── Triggers
└── Camera
    └── Bounds
```

Use `RoomController` somente para identidade, entrada/saída, limites de câmera, estado visual e debug. Lógica específica deve ficar em componentes próprios.

## Identidade e coordenadas

- `room_id`: `StringName` estável em `snake_case`.
- O ponto `(0, 0)` da cena é o canto superior esquerdo da sala.
- `local_bounds` descreve a área jogável local.
- Entradas usam `LEFT_ENTRANCE` e `RIGHT_ENTRANCE` dentro de `Gameplay/Entrances`.
- O mundo posiciona a cena inteira; filhos não devem conhecer o deslocamento global.

## Assets e layout

- Preserve atlas grandes como source assets.
- Extraia regiões reutilizáveis em recursos `AtlasTexture .tres`.
- Posicione `Sprite2D`, `Polygon2D` e demais elementos diretamente na cena.
- Não codifique `Rect2` de recorte nem `Vector2` de layout no controlador da sala.
- Nomeie props pelo papel e variante: `carroca_01`, `cerca_01`, `barricada_01`.

## Baseline e colisão

A convenção da Vila usa:

```text
viewport interno: 320x180
baseline principal: y = 150
chão visual: começa em y = 150
chão físico: topo em y = 150
Nilo em pé: centro do collider em y = 138
```

O sprite de Nilo tem os pés na mesma linha que a base do collider. Em plataformas elevadas, o topo visual e o topo do `CollisionShape2D` devem compartilhar exatamente o mesmo `y` inteiro.

Use retângulos simples para chão e plataformas. Use polígonos apenas quando uma rampa ou silhueta alterar de fato o movimento. Não crie colisão para objetos claramente posicionados no background.

## Z-index

Referência inicial:

| Camada | Faixa |
|---|---:|
| Céu | -30 |
| Background distante | -24 |
| Midground | -12 |
| Decoração atrás do gameplay | -7 a -2 |
| Chão e atores | -1 a 5 |
| Foreground | 10 a 14 |
| Debug | acima da composição local |

Foreground pode cobrir parcialmente as bordas do personagem, mas o espaço central de combate deve permanecer legível.

## Paralaxe e atmosfera

- `CameraParallaxLayer` lê `Camera2D.get_screen_center_position()`; nunca usa a posição do player.
- Configure `camera_anchor` no centro da sala.
- Referência de ratios: céu `0.03`, distante `0.14`, midground `0.50`, gameplay `1.00`, foreground `1.10`.
- Camadas distantes recebem menos contraste e saturação. Foreground é mais escuro que o plano de gameplay.
- Camadas se ocultam fora de `activation_bounds` para não processar quando a câmera está longe.
- Um futuro horizonte contínuo pode reutilizar a mesma textura e âncora entre salas, sem duplicar sóis ou marcos globais.

## EnemySpawn

Cada inimigo da sala parte de um `EnemySpawn` visível no editor, com:

- `enemy_scene`;
- `spawn_id` único;
- `active_if_occupied`;
- `respawn_behavior`;
- direção inicial em `facing`.

O nó visual futuro do inimigo deve poder ser substituído sem alterar IA:

```text
enemy.tscn
├── Visual
├── BodyCollision
├── HealthComponent / PostureComponent
├── Hurtbox
├── Detection
├── Movement
└── StateMachine
```

## Câmera

- `camera_bounds` precisa abranger a área jogável e ter pelo menos 320x180.
- Ao entrar, `RoomController` aplica limites globais com `limit_smoothed`.
- Ao sair, restaura os limites anteriores para manter compatibilidade com o mundo contínuo atual.
- Não chame `reset_smoothing()` durante uma transição normal; ele é reservado a teleportes, respawn e testes.

## Estado do mundo

Agrupe containers da própria sala como:

- `room_occupied_only`: fogo, símbolos, barricadas e atmosfera de ocupação;
- `room_liberated_only`: iluminação recuperada e pequenos sinais de reconstrução.

`RoomController` alterna esses grupos quando `WorldState` emite `world_state_changed`. Inimigos ocupantes são removidos pelo mesmo evento.

## Debug e validação

F3 mostra bounds da sala, camera bounds, entradas e spawns. A validação automatizada é:

```powershell
godot --headless --path . res://tools/room_production_validation.tscn
```

Antes de aceitar uma nova sala, confirme:

1. `room_id`, bounds e camera bounds válidos;
2. entradas dentro dos bounds;
3. spawns fora do chão e das paredes;
4. topo visual e físico de cada superfície no mesmo pixel;
5. paralaxe seguindo a câmera;
6. grupos ocupado/libertado funcionando;
7. passagem por ambas as entradas sem parede invisível;
8. gameplay a 60 FPS na build-alvo.

