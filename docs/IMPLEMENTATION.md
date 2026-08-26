# Decisões de implementação

## Escopo desta etapa

O projeto implementa o vertical slice da Vila do Umbuzeiro com seu primeiro ciclo real de exploração. `wall_jump` e `dash` são adquiridos dentro da Vila e abrem rotas, atalhos e um segredo permanente; habilidades posteriores continuam apenas como dados persistentes.

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

Estados implementados: `IDLE`, `RUN`, `CROUCH`, `JUMP`, `FALL`, `PISTOL`, `RIFLE`, `MELEE`, `SPECIAL`, `HEAL`, `HURT` e `DEAD`.

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

- Pistola: semiautomática, 8 tiros, intervalo mínimo de 0,24 s, recarga de 0,85 s, 1 dano e 0,75 de postura.
- Rifle: 4 tiros, intervalo de 0,38 s, recarga de 1,15 s, longo alcance, 2 de dano, 2,4 de postura e recoil.
- Especial: golpe amplo com 4 de dano, 6 de postura e recarga própria de 5 segundos.
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

## Topologia metroidvania da Vila

As 13 áreas mantêm a faixa principal para preservar o vertical slice, mas agora também formam um grafo: o campanário cria uma subida real, Telhados contém a segunda habilidade, Praça–Armazém oferece rota alternativa e Poço–Igreja vira um atalho tardio. Salas, poderes, segredos, melhorias e atalhos descobertos persistem no save.

Fluxo testável:

```text
Casa -> Rua -> Igreja -> Telhados -> Praça -> Barracos -> Armazém
     -> Pátio -> Beco -> Poço -> Barricada -> Posto -> Zé Tranca -> Pedra Seca
```

O Passo da Pedra é encontrado na Igreja e habilita salto de parede. O Passo da Poeira fica na rota alta dos Telhados e habilita investida com `C`. Voltar à Casa de Nilo com ambos abre o Coração do Sertão, que aumenta a vida máxima permanentemente. O mapa em `M` registra exploração e explicita rotas bloqueadas.

## Arte e pixel-perfect

O projeto usa viewport 320x180, `canvas_items`, filtro nearest e snap 2D. Nilo usa provisoriamente uma folha chibi RGBA de 256x256 px em grade 4x4; inimigos e chefe ainda são recortes de folhas conceituais, mas todos usam transparência RGBA real. A Rua das Cinzas possui cena de produção própria e props por `AtlasTexture`; as outras salas continuam no compositor híbrido sobre o graybox.

## Matriz de teste de runtime

O projeto foi importado no Godot 4.7.1 e completou um smoke test headless de 180 frames sem erros. Para validar sensação de jogo e interação visual:

1. Abrir `project.godot` e confirmar zero erros de parser/carregamento.
2. Iniciar na Casa de Nilo e validar teclado + gamepad.
3. Conferir velocidade máxima sem snap e parada responsiva.
4. Pular 0,10 s depois de sair de uma borda e 0,12 s antes de aterrissar.
5. Comparar salto curto e salto segurado; testar fast fall.
6. Agachar e atravessar/encostar nos blocos sem atravessar o chão.
7. Pressionar K seis vezes, observar um tiro por pressão, recarga de 0,85 s e munição infinita.
8. Gastar 2 cartuchos, observar recarga de 1,20 s, dispersão e recoil.
9. Executar combo 1-2-3, golpe para cima e golpe descendente com bounce.
10. Receber dano durante a cura e confirmar que a carga não foi consumida.
11. Quebrar a postura de um inimigo com o rifle ou o especial e observar 1,2 s de stagger.
12. Ativar o checkpoint da Igreja, morrer e reaparecer com recursos restaurados.
13. Abrir o atalho do Armazém e usá-lo para voltar à Praça.
14. Obter Passo da Pedra na Igreja, subir o campanário e obter Passo da Poeira nos Telhados.
15. Abrir o mapa com M e confirmar salas visitadas, posição, bloqueios e conexões alternativas.
16. Voltar à Casa de Nilo e coletar o Coração do Sertão atrás do selo da investida.
17. Abrir Praça–Armazém e, pelo lado do Poço, o atalho Poço–Igreja; salvar e recarregar.
18. Derrotar Zé Tranca, salvar, reiniciar e confirmar a Vila `LIBERATED`.
19. Repetir o teste com F12 para validar a rota de debug.

## Limitações conhecidas

- A importação, compilação e inicialização automatizada passaram; o playtest humano completo ainda está pendente.
- O mundo ainda usa uma cena global contínua; a topologia agora possui ramificações, mas ainda não há streaming entre salas.
- Ainda não há áudio nem balanceamento final; animação, recortes de inimigos e parte dos VFX permanecem provisórios.
- Batedor, Incendiário e Jagunço de Preto possuem espaço na arquitetura, mas ainda não têm IA própria.
- Os inimigos precisam de spritesheets desenhados com poses e pivôs consistentes antes do uso final.
