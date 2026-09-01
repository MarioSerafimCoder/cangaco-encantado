# Polimento da experiência inicial

## Decisões aplicadas

- A curva horizontal parte de 58% da velocidade-alvo e progride continuamente até 100% em `0,46 s`; não existe mais um salto de velocidade após espera fixa.
- A soltura usa desaceleração de chão e a troca de sentido recebe multiplicador de `1,35`, preservando resposta imediata sem remover a sensação de peso.
- A animação escolhe WALK/RUN pela velocidade real. A fase do passo continua entre as duas faixas e é reiniciada apenas ao partir do repouso ou inverter a direção.
- O primeiro saqueador depende simultaneamente de `first_combat_unlocked` e da conclusão do tutorial `melee`. Isso impede ataque enquanto o jogador ainda lê o comando.
- Pistola e rifle usam gatilhos espaciais dentro de Igreja e Telhados. A Praça continua sendo uma sala segura, sem tutorial básico de disparo.
- O campanário usa as próprias paredes visíveis como superfícies de quique. Os antigos pilares escuros sobrepostos foram removidos.
- Props e colisões complementares criados em runtime ficam dentro de `Environment/RuntimeComposition`, `Geometry/RuntimeComposition`, `Gameplay/Actors` ou `Gameplay/Interactables` da sala correspondente.

## Sequência principal de revisão visual

1. `01_casa_de_nilo.png`
2. `02_saida_da_casa.png`
3. `03_rua_inicio.png`
4. `04_conversa_com_raimundo.png`
5. `05_primeiro_combate.png`
6. `06_rua_final.png`
7. `07_vila_baixa.png`
8. `08_praca_do_umbu.png`
9. `09_igreja_e_cemiterio.png`
10. `10_telhados.png`
11. `11_aquisicao_passo_da_pedra.png`
12. `12_travessia_pelos_telhados.png`
13. `13_climax_manifestacao_encantada.png`

Todos os arquivos são gerados por `res://tools/area01_visual_review.tscn` em `prints_do_jogo/area_01_vertical_slice/` na resolução 1920×1080.

## Validação

- `game_feel_validation.tscn`: curva de aceleração, sincronização visual, salto, combate e escala do herói.
- `area01_vertical_slice_validation.tscn`: ordem do onboarding, bloqueio do primeiro inimigo, diálogos diegéticos, progressão e persistência.
- `room_production_validation.tscn`: treze salas, colisões, pousos, rotas, câmera, recortes e coesão visual.
- `first_rooms_traversal_validation.tscn`: Casa e Rua percorríveis, portas nos dois sentidos e câmera sem travamentos.

## Pendências de avaliação humana

- Calibrar dificuldade e economia depois de uma sessão completa com teclado e controle.
- Confirmar o conforto da curva de câmera em monitores com proporções diferentes de 16:9.
- Avaliar a densidade de inimigos da Vila Baixa depois de jogadores novos completarem o primeiro encontro.
