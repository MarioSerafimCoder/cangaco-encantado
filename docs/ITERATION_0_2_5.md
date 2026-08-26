# Cangaço Encantado — Iteração 0.2.5

## Sprite Integration & Enemy Framing

Esta rodada integra as oito folhas transparentes do kit `generated_0_2_5` ao runtime. Arquitetura civil e militar, chãos, serras, vila distante, preenchimentos, atmosfera, moradores e objetos interativos agora aparecem nas salas correspondentes sem alterar a geometria jogável.

Os sprites de inimigos deixaram de usar divisão uniforme por linhas e colunas. As folhas de Saqueador, Pistoleiro e Zé Tranca possuem espaçamento irregular; por isso, cada estado usado agora declara sua própria região, o limite inferior do conteúdo e uma baseline visual. O animador compensa a diferença de altura de cada quadro para que os pés não saltem e para que chapéu, arma e efeitos não sejam cortados.

## Validação

- `res://tools/room_production_validation.tscn` verifica limites das regiões e exige margem transparente acima e abaixo de cada pose.
- `res://tools/game_feel_validation.tscn` confirma que as mudanças visuais não alteraram movimento, combate ou animação de tiro.
- `res://tools/mvp_visual_test.tscn` atualiza os prints oficiais, incluindo `inimigos_escala_e_recorte.png`.
- `res://tools/environment_visual_test.tscn` gera o conjunto `prints_do_jogo/iteracao_0_2_5/`.
