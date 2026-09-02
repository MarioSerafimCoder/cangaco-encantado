# Gates do vertical slice

## Sempre

- Preservar trabalho local e revisar `git diff`.
- Executar `tools/validate_project.ps1`.
- Executar testes específicos do domínio alterado.
- Registrar problemas conhecidos e não esconder regressões.

## Gameplay ou IA

- `game_feel_validation.tscn`
- `combat_fairness_validation.tscn`
- `enemy_ai_validation.tscn` quando inimigos forem alterados

## Salas, câmera ou física

- `room_production_validation.tscn`
- `first_rooms_traversal_validation.tscn`
- `metroidvania_validation.tscn`

## UI, fluxo ou save

- `boot_menu_validation.tscn`
- `menu_flow_validation.tscn`
- `hud_validation.tscn`
- `ui_ux_polish_validation.tscn`

## Visual

Gerar `area01_visual_review.tscn`, inspecionar as capturas relevantes e atualizar a pasta oficial quando a mudança for grande.

## Gate amplo

Executar `area01_vertical_slice_validation.tscn` e o fluxo inicial relevante. Não declarar “sem regressões” apenas porque testes estáticos passaram.
