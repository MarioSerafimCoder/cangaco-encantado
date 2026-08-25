# Iteração 0.2.2 — Production Pipeline & Rua das Cinzas Final Slice

## Resultado

A Rua das Cinzas deixou de receber chão, inimigos e composição principal do gerador global. A sala agora existe como `rua_das_cinzas.tscn`, posicionada como uma unidade dentro do percurso contínuo atual.

Na cena, ambiente, geometria, gameplay e câmera compartilham o mesmo sistema de coordenadas. O chão visual começa em `y=150`, exatamente onde termina o espaço físico. Entradas, spawns e limites são nodes editáveis; props de atlas usam recursos `AtlasTexture`.

O paralaxe passou a derivar do centro real da `Camera2D`. O estado da Vila alterna containers `room_occupied_only` e `room_liberated_only`, enquanto os encontros da Rua nascem de `EnemySpawn`.

## Componentes reutilizáveis

- `RoomController`: identidade, bounds, entradas, câmera, estado e debug.
- `CameraParallaxLayer`: scroll baseado em câmera e ativação por proximidade.
- `EnemySpawn`: referência de cena, ID, estado de ocupação e direção inicial.
- `ROOM_PRODUCTION_PIPELINE.md`: convenções para converter a próxima sala.
- `NILO_ANIMATION_SPEC.md`: contrato visual da futura folha de animação.

## Limitações registradas

- As outras 12 salas continuam no sistema híbrido de atlas sobre o graybox.
- O mundo ainda não possui streaming; a cena da Rua é instanciada dentro da faixa contínua existente.
- As construções da Rua são background e não recebem colisão. A área jogável desta versão é deliberadamente plana.
- O fogo integrado é uma composição estática leve; não há spritesheet animado nem iluminação dinâmica final.
- Saqueador e Pistoleiro ainda usam recortes de concept sheets e precisam de folhas próprias.
- `respawn_behavior` prepara o contrato de dados, mas não existe encounter director ou persistência individual de spawn.
- O HUD já possui `hud.tscn`, porém seus controles ainda são construídos gradualmente pelo script.
- Testes estruturais não medem estética nem garantem 60 FPS em todo hardware. O checklist humano da sala continua obrigatório.
- A suavidade de entrada e saída da câmera precisa de playtest prolongado com teclado e gamepad.

## Verificação

```text
VALIDAÇÃO ESTÁTICA OK
GAME_FEEL_VALIDATION_OK
ROOM_PRODUCTION_VALIDATION_OK
smoke test: 300 frames
movement lab: 90 frames
```

As seis capturas comparáveis ficam em `prints_do_jogo/rua_das_cinzas_0_2_2/`.

