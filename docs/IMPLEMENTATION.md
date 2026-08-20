# Decisões de implementação

## Escopo desta etapa

O projeto implementa o vertical slice da Vila do Umbuzeiro sem tentar antecipar o jogo inteiro. Todas as habilidades futuras (`dash`, `wall_jump`, `double_jump`, `air_dash`, movimento aquático e magia) existem apenas como dados persistentes desativados; nenhuma é necessária para chegar a Zé Tranca.

## Arquitetura

O fluxo de dependências é propositalmente simples:

```text
InputMap
  -> NiloPlayer (orquestração)
       -> PlayerMovement
       -> PlayerCombat
       -> PlayerStateMachine
       -> HealthComponent / Hurtbox

WeaponData / PlayerConfig / EnemyData
  -> componentes de gameplay

VilaGraybox
  -> RoomTrigger / Checkpoint / ShortcutDoor / LiberationGate
  -> EnemyBase
       -> Detection / Movement / StateMachine
       -> HealthComponent / PostureComponent / Hurtbox

EventBus
  -> GameState / WorldState / SaveManager / HUD
```

`player.gd` coordena os componentes e conhece a cena; os números de balanceamento ficam em `Resource`. A IA básica compartilha `EnemyBase`, e a diferença entre Saqueador e Pistoleiro vem de `EnemyData.Behavior` e dos respectivos recursos.

## State machine do player

Estados implementados: `IDLE`, `RUN`, `CROUCH`, `JUMP`, `FALL`, `SHOOT`, `SHOTGUN`, `MELEE`, `HEAL`, `HURT` e `DEAD`.

A state machine mantém um lock curto para ações que não devem se sobrepor. `HURT` e `DEAD` podem interromper qualquer ação; dano interrompe `HEAL`. Locomoção é atualizada pelo componente de movimento e só reassume o estado quando o lock termina.

Estados futuros entram na enumeração e em componentes dedicados, sem transformar `player.gd` em uma lista crescente de condicionais.

## Movimento

Os valores vêm de `resources/player/player_config.tres`:

| Parâmetro | Valor |
|---|---:|
| Velocidade | 120 px/s |
| Aceleração | 1400 px/s² |
| Desaceleração | 1800 px/s² |
| Controle aéreo | 75% |
| Gravidade | 900 px/s² |
| Salto | -290 px/s |
| Fast fall | 1,35x |
| Coyote time | 0,10 s |
| Jump buffer | 0,12 s |

Soltar o botão reduz a velocidade ascendente, produzindo salto variável. Agachar reduz a altura do collider e a velocidade horizontal. O graybox evita corredores que dependam de habilidades futuras.

## Combate

Todos os ataques geram `AttackHitbox` ou `CombatProjectile` com payload uniforme: time, dano, dano de postura, knockback, identificador e fonte.

- Revólver: 6 tiros, 0,20 s, recarga de 0,85 s, 1 dano e 0,75 de postura.
- Espingarda: 2 tiros, 0,45 s, recarga de 1,20 s, 3 projéteis curtos, 2 de dano, 3,2 de postura e recoil.
- Facão: combo de três passos; o terceiro ganha dano/postura/knockback. `UP` cria hitbox vertical; `DOWN` no ar cria hitbox descendente e confirma bounce.
- Cura: 2 cargas, 2 HP, 1,10 s. A carga só é consumida ao completar a animação lógica.

Postura se regenera fora da quebra. Ao chegar a zero, o alvo entra em `STAGGER` por 1,2 s e então recupera a barra inteira.

## Mundo e persistência

`WorldState` guarda estados de região e flags sistêmicas. A Vila começa `OCCUPIED`; derrotar Zé Tranca ou apertar F12 chama `liberate_vila()`.

A mudança é reativa:

- inimigos hostis da Vila são removidos;
- incêndios deixam de ser desenhados;
- barricada e saída para Pedra Seca abrem;
- Praça recebe marcadores de moradores;
- save automático registra o novo estado.

Esse modelo permite eventos futuros como `water_restored` e `wind_restored` sem duplicar mapas.

O save usa JSON versionado. Ele persiste checkpoint/posição, vida, cargas, habilidades, bosses, atalhos, segredos, estado de regiões e flags globais. Não persiste nós de cena nem coordenadas de spawn hardcoded.

## Graybox da Vila

As 13 áreas usam as dimensões da especificação e formam, nesta primeira versão, uma faixa contínua navegável. A separação visual e os triggers já são por sala; numa próxima iteração, cada trecho deve migrar para cena própria sem mudar o contrato de dados.

Fluxo testável:

```text
Casa -> Rua -> Igreja -> Telhados -> Praça -> Barracos -> Armazém
     -> Pátio -> Beco -> Poço -> Barricada -> Posto -> Zé Tranca -> Pedra Seca
```

O Poço contém uma descida visual parcial e bloqueio explícito. O atalho do Armazém é aberto por dentro e passa a transportar Nilo de volta à Praça. A Igreja restaura vida, munição e cargas.

## Arte e pixel-perfect

O projeto usa viewport 320x180, `canvas_items`, filtro nearest e snap 2D. As imagens de referência foram copiadas sem alteração, porém não têm alpha e não formam grades regulares. Por isso nenhuma é importada automaticamente como animação do gameplay nesta etapa.

## Matriz de teste de runtime

O projeto foi importado no Godot 4.7.1 e completou um smoke test headless de 180 frames sem erros. Para validar sensação de jogo e interação visual:

1. Abrir `project.godot` e confirmar zero erros de parser/carregamento.
2. Iniciar na Casa de Nilo e validar teclado + gamepad.
3. Conferir velocidade máxima sem snap e parada responsiva.
4. Pular 0,10 s depois de sair de uma borda e 0,12 s antes de aterrissar.
5. Comparar salto curto e salto segurado; testar fast fall.
6. Agachar e atravessar/encostar nos blocos sem atravessar o chão.
7. Gastar 6 tiros, observar recarga de 0,85 s e munição infinita.
8. Gastar 2 cartuchos, observar recarga de 1,20 s, dispersão e recoil.
9. Executar combo 1-2-3, golpe para cima e golpe descendente com bounce.
10. Receber dano durante a cura e confirmar que a carga não foi consumida.
11. Quebrar a postura de um inimigo com a espingarda e observar 1,2 s de stagger.
12. Ativar o checkpoint da Igreja, morrer e reaparecer com recursos restaurados.
13. Abrir o atalho do Armazém e usá-lo para voltar à Praça.
14. Chegar à arena sem dash/wall jump/double jump.
15. Derrotar Zé Tranca, salvar, reiniciar e confirmar a Vila `LIBERATED`.
16. Repetir o teste com F12 para validar a rota de debug.

## Limitações conhecidas

- A importação, compilação e inicialização automatizada passaram; o playtest humano completo ainda está pendente.
- O graybox ainda é uma faixa única, não um sistema de streaming de salas.
- Não há animação, áudio, hitstop, partículas nem balanceamento final.
- Batedor, Incendiário e Jagunço de Preto possuem espaço na arquitetura, mas ainda não têm IA própria.
- A arte conceitual precisa ser convertida em spritesheets transparentes antes do uso em produção.
