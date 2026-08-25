# Changelog

## 0.2.3 — Visual Gap Kit & Shooting Readability

### Assets integrados

- Cinco atlas corrigidos foram importados com transparência RGBA para HUD, props de preenchimento, transições, VFX e animações de tiro de Nilo.
- A Rua das Cinzas recebeu pedras, capim seco, cacto, madeira, ossos e limites visuais sem alterar a colisão plana.
- O fogo estático foi substituído por fogo e fumaça animados a partir de um atlas reutilizável.
- As folhas-fonte, instruções e o registro completo dos prompts permanecem arquivados fora do runtime.

### HUD

- Painel de status, aviso de sala, placa de estado da Vila, barra de chefe e faixa de ajuda usam molduras em pixel art.
- As molduras preservam o layout compacto e não reintroduzem o retângulo opaco de sombra.

### Disparos

- Revólver passou de 0,08 s em uma pose para 0,24 s com antecipação, frame ativo e recuperação.
- Espingarda passou a usar 0,36 s com brace, recoil forte e settle.
- Projéteis saem no momento visual do disparo, após 0,06 s no revólver e 0,08 s na espingarda.
- Flash procedural duplicado foi removido nas duas armas porque as folhas dedicadas já contêm o clarão.
- Validação de game feel agora exige mira, disparo ativo e recuperação na sequência de seis poses.
- Prints de revólver e espingarda capturam exatamente o frame ativo da nova animação.

## 0.2.2 — Production Pipeline & Rua das Cinzas Final Slice

### Sala de produção

- Rua das Cinzas passou a possuir cena própria com arte, geometria, gameplay, câmera e lógica separados.
- Chão visual e colisão compartilham a baseline `y=150`; entradas e spawns agora são editáveis no Godot.
- `RoomController` fornece identidade, bounds, limites de câmera, entradas, estado visual e debug reutilizáveis.
- `EnemySpawn` substituiu posições hardcoded de Saqueador e Pistoleiro nessa sala.
- Props derivados dos atlas agora usam recursos `AtlasTexture .tres` e nodes editáveis.

### Visual e câmera

- Paralaxe da Rua passou a acompanhar a posição real da `Camera2D`, com processamento restrito à vizinhança da sala.
- Camadas de céu, atmosfera distante, vila, gameplay e foreground foram organizadas dentro da cena.
- Estados `OCCUPIED` e `LIBERATED` alternam containers visuais por grupo.
- Arte e encontros duplicados foram removidos do `VilaArtDecorator` e do spawn procedural para esta sala.

### Movimento e pipeline

- Bob da corrida agora alterna contatos e passagens, retornando à baseline nos contatos.
- Limiares de movimento e corrida foram separados, com histerese na ativação da corrida.
- Criados `ROOM_PRODUCTION_PIPELINE.md`, `NILO_ANIMATION_SPEC.md` e checklist manual da sala.
- Adicionada validação estrutural específica e uma série de seis screenshots comparáveis.

## 0.2.1 — Fluid Movement & Visual Cohesion

### Movimento e câmera

- `run_phase` contínuo passou a comandar frames, bob e contatos dos pés.
- Transições visuais próprias para arrancada, parada, virada, decolagem e pouso.
- Fases aéreas distinguem subida, ápice, queda e queda rápida.
- Câmera ganhou look-ahead horizontal suave e leitura vertical em quedas.

### Combate

- Facão dividido em antecipação, ativo, continuidade e recuperação.
- Buffer de entrada para o combo de três golpes.
- Cortes horizontal, para cima e para baixo com efeitos distintos.
- Hitstop calibrado por arma e quebra de postura.
- Projéteis agora orientam corpo e rastro pela direção da velocidade.
- Canalização e conclusão da cura possuem feedbacks diferentes.

### Apresentação

- Rua das Cinzas tornou-se o primeiro alvo de qualidade com três camadas rasterizadas e paralaxe real.
- Oito atlas ambientais com transparência real passaram a cobrir as 13 áreas da Vila do Umbuzeiro.
- Casa de Nilo, Igreja, Praça, Poço, Barricada, Posto e Arena receberam landmarks rasterizados próprios.
- Estruturas e marcadores procedurais duplicados foram retirados onde conflitavam com a arte nova, sem mudar colisões.
- HUD foi reduzido e informações contextuais passaram a desaparecer automaticamente.
- Zé Tranca recebeu contorno quente para preservar leitura na arena.
- Praça libertada usa moradores provisórios em linguagem pixelada.
- Redesenho periódico do mundo inteiro foi removido.

### Ferramentas

- Cena `res://tools/movement_lab.tscn` para testar corrida, virada, salto, queda e combo.
- Validação automatizada expandida para movimento, combate, projétil, hitstop e HUD.
- Prints oficiais regenerados após a mudança visual.
- A suíte de capturas agora registra individualmente as áreas 01 e 03–13, além da Rua das Cinzas.
- Camadas da Rua das Cinzas, Saqueador, Pistoleiro e Zé Tranca receberam transparência RGBA definitiva; os shaders de recorte de fundo foram removidos.
