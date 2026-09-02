# Iteração 0.2.3 — Visual Gap Kit & Shooting Readability

## Resultado

As cinco folhas devolvidas com transparência foram preservadas na pasta de preparação e copiadas para diretórios definitivos em `assets/`. O jogo agora usa os novos recursos no runtime, sem depender de chroma key ou shader de remoção de fundo.

A HUD recebeu molduras próprias para status, avisos de sala e mundo, ajuda e chefe. A Rua das Cinzas ganhou preenchimentos visuais e peças de transição nas extremidades sem alterar a navegação nem criar colisões invisíveis. Fogo e fumaça usam um animador de faixa de atlas reutilizável.

## Tiro de Nilo

- Revólver: seis poses em 0,24 s, com projétil sincronizado em 0,06 s.
- Espingarda: seis poses em 0,36 s, com projétil sincronizado em 0,08 s.
- Pose 0: base; 1: levantar arma; 2: mira; 3: disparo; 4: recuo; 5: recuperação.
- O sprite dedicado é escalado e deslocado apenas durante o estado de tiro para manter tamanho e pés coerentes com a folha principal.
- Os clarões já contidos nos frames ativos substituem o efeito procedural duplicado.

## Recursos adicionados

- `assets/ui/hud/`: atlas e recortes das molduras.
- `assets/environments/rua_das_cinzas/fillers/`: atlas e recortes de preenchimentos/transições.
- `assets/sprites/usados/efeitos/vfx_ocupacao_e_tiros.png`: atlas de fogo, fumaça, poeira e impactos.
- `assets/sprites/usados/personagens/jogador/nilo_animacoes_de_tiro.png`: duas sequências de seis poses.
- `scripts/fx/atlas_strip_animator.gd`: animação reutilizável de faixas horizontais.

## Validação

- Parsing/importação do Godot sem erros.
- Validação estática do projeto.
- Validação automatizada de game feel.
- Validação do contrato da sala de produção.
- Execução da cena principal e do laboratório de movimento.
- Regeneração das capturas oficiais e das seis comparações da Rua das Cinzas.

## Limitações conscientes

- Os atlas foram gerados como pranchas livres, não como grids matemáticos uniformes; cada elemento integrado usa um recorte `AtlasTexture` explícito.
- A nova folha de tiro cobre apenas direção horizontal. Mira vertical continua usando a lógica de projétil existente sem pose dedicada.
- Poeira e impactos presentes no atlas ainda ficam reservados para próximas substituições dos efeitos procedurais.
