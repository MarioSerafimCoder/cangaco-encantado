# Prints do jogo

Esta pasta mantém as capturas visuais oficiais da build atual. Os arquivos devem ser sobrescritos sempre que houver uma mudança visual grande em personagens, HUD, cenário, iluminação ou VFX.

## Atualização automática

Para revisar a Área 01 completa em 1920x1080, execute:

```text
res://tools/area01_visual_review.tscn
```

Ela sobrescreve `area_01_vertical_slice/` com quinze capturas nomeadas, incluindo menu inicial, pausa, composição geral e porta de saída da Casa de Nilo, Rua das Cinzas sem oclusão, Vila Baixa, Praça, loja, diálogo, Igreja, Telhados, Subterrâneo, Grutas, Santuário e o diário do personagem. Esse é o conjunto visual oficial do vertical slice 0.4.1.

Execute a cena Godot:

```text
res://tools/mvp_visual_test.tscn
```

Ela atualiza as capturas com nomes descritivos da ação apresentada:

- `andando_no_mapa_01.png`
- `heroi_parado_respirando.png`
- `heroi_piscando.png`
- `correndo_apos_2_segundos.png`
- `dano_de_personagem.png`
- `combate_com_ze_tranca.png`
- `tiro_de_pistola.png`
- `tiro_de_rifle.png`
- `ataque_de_facao.png`
- `ataque_finalizador_de_facao.png`
- `ataque_especial.png`
- `inimigos_escala_e_recorte.png`
- `vila_libertada_praca_do_umbu.png`

As grandes mudanças ambientais também atualizam `ambiente_01_...png` até `ambiente_13_...png`, com uma captura para cada sala que recebeu o novo kit visual. A Rua das Cinzas permanece representada por `andando_no_mapa_01.png`.

A pasta `rua_das_cinzas_0_2_2/` contém seis capturas comparáveis da primeira sala de produção e continua sendo sobrescrita nas grandes mudanças visuais. Execute `res://tools/rua_das_cinzas_visual_test.tscn` para atualizá-las.

A pasta `iteracao_0_2_4/` é o conjunto de aceitação do passe ambiental. Execute `res://tools/environment_visual_test.tscn` e `res://tools/nilo_scale_comparison.tscn` para atualizar:

- `04_telhados.png`
- `05_praca_occupied.png`
- `05_praca_liberated.png`
- `06_barracos.png`
- `12_posto.png`
- `13_arena.png`
- `nilo_idle.png`
- `nilo_run.png`
- `nilo_revolver.png`
- `nilo_shotgun.png`
- `nilo_comparacao_escala.png`

A pasta `iteracao_0_2_5/` registra a aplicação das novas folhas transparentes nas salas de produção. Ela é atualizada por `res://tools/environment_visual_test.tscn`.

As capturas devem ser executadas com renderização normal. O modo `--headless` do Godot 4.7 usa um renderizador dummy e não disponibiliza a textura do viewport para `save_png()`.

Não use nomes genéricos como `screenshot1.png`. Se uma nova captura for adicionada, o nome deve descrever claramente a ação, personagem ou local mostrado.
