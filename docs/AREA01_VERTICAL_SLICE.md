# Área 01 — Vila do Umbuzeiro

## Escopo

Este vertical slice transforma a primeira parte do jogo em uma macroárea de metroidvania completa. O objetivo é apresentar Nilo, a Vila ocupada, o combate, a exploração e o primeiro contato com o Encantado sem antecipar um chefe que pertence a outra etapa da história.

O áudio não faz parte desta entrega. Música, efeitos e mixagem ficam reservados para um passe futuro.

## Fluxo

1. Nilo desperta em uma casa delimitada por paredes, recebe orientação contextual, pode examinar uma lembrança e usa a porta para sair à Rua das Cinzas.
2. O primeiro combate é liberado depois de encontrar o morador ferido.
3. A Praça do Umbu funciona como centro seguro, com moradores e mercador.
4. Igreja, Telhados, Cripta, Subterrâneo, Grutas e Poço apresentam rotas verticais, habilidades e atalhos.
5. As cavernas aprofundam a exploração e conduzem ao Santuário.
6. A manifestação conclui a área sem chefe, muda o estado da Vila e libera retorno rápido e saída segura do beta.

## Sistemas entregues

- Treze `RoomController` com limites e transições centralizadas de câmera.
- Menu inicial confiável, porta animada nos dois sentidos e tutorial de abertura encerrado ao chegar à rua.
- Oito NPCs e diálogos JSON com variantes, escolhas, eventos e bloqueio seguro do combate durante conversas.
- Loja com cinco itens, moeda do sertão, inventário e compras únicas.
- Quatro cordéis colecionáveis e um coração permanente secreto.
- Três checkpoints, atalhos persistentes e diário navegável com mapa, inventário, habilidades e amuletos.
- Save para progressão, moeda, inventário, compras, estados de NPC, diálogos, áreas, salas e atalhos.
- Encerramento de beta que não deixa o jogador preso e não cria um chefe na Área 01.

## Arte

Os oito atlas da rodada estão em `assets/area_01/`. Eles cobrem interior e estrutura da Casa de Nilo, travessia, arquitetura, Cripta/Subterrâneo, estrutura e decoração de Grutas/Cavernas e interface de diálogo/loja. As folhas entregues para remoção do fundo permanecem arquivadas em `assets_para_remover_fundo/`.

Volumes geométricos simples são usados apenas para colisão e depuração. A apresentação normal utiliza sprites e camadas rasterizadas.

## Validação

- `res://tools/area01_vertical_slice_validation.tscn`: fluxo, porta da casa, tutorial, recortes de NPCs, diálogo, loja, economia, conclusão e persistência.
- `res://tools/boot_menu_validation.tscn`: abertura determinística do menu inicial, pausa do mundo e visibilidade correta do HUD.
- `res://tools/room_production_validation.tscn`: estrutura das treze salas, bounds, chão, entradas, câmera e pousos reais em caixas/carroças/telhados.
- `res://tools/area01_visual_review.tscn`: quinze capturas 1920x1080 em `prints_do_jogo/area_01_vertical_slice/`, incluindo menu inicial, pausa e conferência de oclusão na Rua.
- `tools/validate_project.ps1`: suíte automatizada consolidada.

O fechamento da beta ainda requer uma sessão manual completa com teclado e gamepad para calibrar duração, dificuldade e economia com observação humana.
