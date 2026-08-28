# Changelog

## UI/UX Polish — 0.4.2

- Criado Theme central inspirado em couro, madeira, areia, ferrugem e ouro envelhecido, além de componentes reutilizáveis para painel, botão, glyph, toast, moeda e diálogo.
- Menu inicial passou a usar a composição visual e o logotipo oficiais; ações foram simplificadas para Continuar, Novo jogo, Opções e Sair.
- Menu de pausa foi reduzido a Retomar, Diário, Opções, Menu Principal e Sair.
- Configurações agora incluem vibração, intensidade de tremor, redução de flashes e velocidade do texto, preservando volume, fullscreen, resolução e VSync.
- Criado `InputGlyphResolver`, com troca automática entre teclado e gamepad e atlas gráfico central para prompts contextuais.
- Espaço/A deixou de acelerar a corrida e voltou a ser exclusivo do salto; a corrida automática após dois segundos foi preservada.
- Banner permanente de controles foi substituído por onboarding contextual, progressivo e persistente no save.
- Moeda ganhou contador próprio; estado da região, objetivo, habilidades, segredos, relatos e melhorias usam fila de notificações com prioridade.
- Diálogo passou para caixa horizontal inferior, reserva espaço para escolhas e respeita a velocidade de texto configurada.
- Loja ganhou colunas reais, ícones, preço separado, descrição legível e preservação de foco após compra.
- Diário preserva sua origem, retorna ao Pause quando aberto pelo Pause, permite selecionar salas e mostra detalhes sem revelar áreas desconhecidas.
- Abas de itens, habilidades e amuletos receberam iconografia, nomes curados e proteção contra spoilers.
- Save avançou para a versão 4 mantendo defaults compatíveis com saves anteriores.
- Adicionada validação específica do passe de UI/UX e atualizadas as suítes de game feel, menu, HUD, Área 01 e metroidvania.
- Nenhum sistema ou asset de áudio foi adicionado nesta etapa.

## Correção de escala, travessia e diário — 0.4.1

- A Casa de Nilo foi reduzida para uma sala de 640 px, com móveis menores, porta destacada e nenhum NPC fora de contexto no interior.
- NPCs agora aparecem e processam somente na sala à qual pertencem.
- Carroças, caixas, varandas e fachadas externas foram reescaladas e assentadas na linha do chão.
- Carroças e caixas passaram a ser obstáculos com topo físico, permitindo saltar e permanecer sobre eles.
- A altura física das carroças passou a usar o estrado caminhável, sem prender a colisão ao pixel mais alto da carga; caixas e degraus básicos ficaram dentro do alcance real do salto.
- Vila Baixa e Telhados receberam fachadas completas no lugar de casas flutuantes, incompletas ou cortadas.
- Telhados deixou de misturar duas composições sobrepostas; todas as coberturas visíveis agora são plataformas.
- As laterais superiores das casas aceitam o quique depois de obter o Passo da Pedra, e obstáculos próximos formam rotas de acesso.
- Cactos decorativos e a entrada da Cripta foram reduzidos para a escala de Nilo.
- A versão 0.4.1 ainda permitia aceleração ao segurar Espaço; esse conflito foi removido na 0.4.2.
- M abre o Diário de Nilo com abas de mapa, itens, habilidades e amuletos; A/D alterna as abas.
- A revisão visual oficial passou a incluir o menu de habilidades do personagem.
- Diálogos agora aplicam a fonte pixel art, ocupam menos tela e mostram a tecla de avanço; a loja ganhou foco temático, comandos visíveis e espaçamento sem sobreposição.
- O menu de pausa foi ampliado para acomodar as sete ações sem escapar da moldura, e a revisão visual passou a registrar menu inicial e pausa.
- O teste de produção agora derruba Nilo sobre plataformas representativas e valida a altura exata do pouso em Rua, Vila Baixa e Telhados.
- A árvore seca e os cactos panorâmicos da Rua foram movidos para trás da arquitetura e do gameplay, deixando porta, NPCs, Nilo e obstáculos sempre legíveis.

## Área 01 — vertical slice da Vila do Umbuzeiro — 0.4.0

- As treze salas foram reorganizadas como uma macroárea coerente, com rotas horizontais, verticais, atalhos e retorno após adquirir habilidades.
- Casa de Nilo, arquitetura da Vila, Cripta, Subterrâneo, Grutas, Cavernas e Santuário receberam os novos atlas tratados com transparência.
- Oito moradores ganharam interação e diálogos orientados por JSON, com variantes condicionais, escolhas e eventos persistentes.
- A Praça do Umbu tornou-se um centro seguro com mercador, cinco itens, moeda, inventário e compras únicas.
- Quatro cordéis e uma melhoria permanente de vida passaram a recompensar exploração e revisita.
- Três checkpoints, fade de entrada/morte, mapa revisado e transições centralizadas de câmera completam o fluxo de navegação.
- O encontro inicial só começa depois de Nilo encontrar o morador ferido; a Praça não cria inimigos.
- A manifestação no Santuário conclui a área sem chefe, libera a Vila, abre retorno rápido e conduz a uma saída segura de beta.
- Save ampliado para moeda, inventário, compras, NPCs, diálogos, áreas, salas visitadas e atalhos.
- Criadas validação funcional da Área 01 e uma suíte visual 1920x1080 com onze capturas nomeadas.
- Música e efeitos sonoros foram mantidos fora desta entrega, conforme escopo definido.
- O boot normal agora abre o menu inicial de forma determinística, inclusive ao iniciar pela cena principal no editor.
- Corrigida a camada preta de transição que permanecia acima do menu e fazia o jogo parecer travado ao iniciar pelo Godot.
- A Casa de Nilo recebeu parede contínua, teto, piso modular sem fendas e porta interativa com fade nos dois sentidos.
- Um guia contextual orienta movimento e saída apenas na primeira visita à casa.
- Grutas e setores subterrâneos receberam uma segunda camada estrutural, removendo faixas pretas entre plataformas.
- Corrigida a grade real 4×2 do atlas de moradores (1313×1198), eliminando recortes invadidos e fragmentos soltos.
- Plataformas do segredo da casa ficam ocultas até obter o Passo da Poeira, evitando poluição visual na abertura.
- A suíte visual passou a registrar também a porta de saída da casa, totalizando onze capturas oficiais.

## Pipeline integral, câmera e coesão visual — 0.3.4

- Casa de Nilo, Igreja Velha, Armazém, Pátio, Beco, Poço e Barricada foram convertidos em cenas completas com `RoomController`.
- As treze áreas agora possuem ambiente, paralaxe, chão, colisões, entradas, triggers e gameplay no mesmo espaço local.
- Arte das sete salas foi materializada como nós editáveis; o `VilaArtDecorator` deixou de ser instanciado no runtime.
- Plataformas do Armazém, obstáculo do Poço e spawns de Armazém/Pátio/Beco saíram do graybox global e foram incorporados às respectivas salas.
- `CameraDirector` tornou-se a única autoridade de enquadramento e interpola limites entre salas adjacentes em 0,34 s.
- Teleportes de longa distância evitam a varredura involuntária por todo o mapa.
- Corrigida a âncora de paralaxe das salas de 320 px, que ainda usava o centro de uma sala de 640 px.
- Todas as salas usam limites verticais padronizados e perfil cromático comum.
- Herói, inimigos, chefe e cenários fixam filtro nearest; Saqueador e Pistoleiro foram recalibrados para aproximadamente 40 px de altura útil.
- Validação de produção ampliada para treze salas, transição de câmera, ausência do compositor híbrido, nitidez e perfil de cor.

## Identidade metroidvania do mapa — 0.3.3

- Passo da Pedra e Passo da Poeira passaram de flags futuras a habilidades jogáveis de salto de parede e investida.
- Igreja recebeu uma subida vertical de campanário conectada à rota alta dos Telhados.
- Praça e Armazém ganharam uma rota alternativa controlada pela investida.
- Poço passou a abrir um atalho persistente de retorno à Igreja pelo lado tardio da exploração.
- Casa de Nilo ganhou um segredo de retorno que exige as duas habilidades e concede vida máxima permanente.
- Salas visitadas, posição no mapa, habilidades, atalhos, segredos e melhorias permanentes agora persistem no save.
- M abre um mapa navegável com treze áreas, conexões verticais, bloqueios, posição atual e contador de segredos.
- Aquisições importantes exibem um aviso com o novo comando ou efeito permanente.
- Adicionada validação automatizada da topologia, progressão, bloqueios, mobilidade, mapa e schema de persistência.

## IA e animações inimigas — 0.3.2

- Saqueadores e pistoleiros patrulham ao redor do posto, esperam nos extremos e retornam quando se afastam demais.
- Percepção passou a exigir linha de visão; ao perder Nilo, o inimigo investiga apenas a última posição vista por tempo limitado.
- Limites de perseguição impedem inimigos de abandonar permanentemente sua área de guarda.
- Sondas de parede e beirada interrompem o movimento antes de obstáculos ou quedas.
- Pistoleiros recuam quando pressionados, avançam quando estão longe e atiram na faixa de distância preferida.
- Antecipações receberam marcador progressivo, linha de mira ampliada e indicação da área corpo a corpo.
- Reação a dano agora possui recuo, tremor, inclinação e flash alternado.
- Mortes comuns e do chefe ficaram mais longas, com queda, compressão e desaparecimento gradual.
- Corrigido conflito que podia recolocar o inimigo no estado de dano depois de receber o golpe fatal.
- Rua das Cinzas, Praça do Umbu, Barracos Queimados e Posto de Comando receberam novas formações mistas.
- Adicionada validação automatizada para patrulha, memória, paredes, distância tática, dano, morte e composição de encontros.

## Menu inicial e pausa — 0.3.1

- O jogo agora abre em um menu inicial completo, com o mundo congelado ao fundo.
- Continuar só fica disponível quando existe um save ou uma sessão em andamento.
- Novo jogo pede confirmação antes de apagar o progresso existente.
- Escape abre uma interface real de pausa e também retorna das telas secundárias.
- Menus inicial e de pausa oferecem Continuar, Novo jogo, Configurações, Controles e Sair.
- Configurações persistentes incluem volume geral, tela cheia e tremor de câmera.
- Tela de controles reúne movimentação, combate, cura, interação e pausa.
- Fonte pixel, molduras do atlas, foco por teclado e suporte aos comandos de interface do controle foram aplicados ao fluxo.
- Adicionada validação automatizada para navegação, pausa, conteúdo e confirmação destrutiva.

## Reconstrução profissional do HUD — 0.3.0

- Painel principal reduzido para 136 × 36 pixels na resolução interna e reorganizado em duas linhas.
- Vida passou a usar os diamantes preenchidos e vazios do atlas oficial.
- Pistola, rifle, ataque especial e cabaça receberam iconografia própria, sem abreviações textuais.
- Munição da pistola usa projéteis individuais; munição do rifle usa cartuchos do atlas.
- Recarga ganhou arco de progresso e marcador giratório sobre a arma correspondente.
- Ataque especial ganhou medidor contínuo de cooldown e brilho quando está disponível.
- Cura ganhou barra de canalização junto à cabaça.
- Perda e recuperação de vida, munição e cargas agora disparam pulsos, cores e pequenos impactos visuais.
- Fonte pixel Tiny5, sob licença OFL, substitui a fonte padrão em títulos e avisos do HUD.
- Barra de Zé Tranca foi ampliada e agora mostra nome, vida suavizada, duas fases e postura.
- Adicionada validação automatizada exclusiva para estrutura e estados do HUD.

## Passe de preenchimento ambiental 0.2.7

- Quatro casas completas substituem os blocos chapados de Telhados da Vila.
- A Praça do Umbu recebeu pavimento de pedra com caminho central.
- Rua das Cinzas e demais salas receberam acabamento contínuo de rua junto à baseline.
- O Posto de Comando recebeu uma muralha rasterizada no lugar do fundo geométrico.
- Segmentos de solo das salas largas agora se sobrepõem para não deixar fenda central.

## Atualização do arsenal e sprites do herói

- Novas folhas 4×4 de locomoção e combate aplicadas com margem transparente por célula para evitar cortes.
- Revólver e espingarda foram substituídos por pistola semiautomática e rifle de longo alcance.
- A quarta linha da folha de combate agora executa um ataque especial amplo com recarga própria.
- HUD, controles, dados de armas, testes e capturas foram atualizados para o novo arsenal.

## 0.2.6 — Nilo Animation Upgrade

### Herói

- Duas novas folhas transparentes substituem o boneco-guia e a antiga folha de tiros.
- Idle alterna três poses de respiração e executa uma piscada curta a cada 4,8 segundos.
- Nilo começa andando a 58% da velocidade máxima e passa a correr após 2 segundos mantendo a mesma direção.
- Soltar ou inverter o movimento reinicia o contador da corrida.
- Revólver e espingarda usam sequências completas de mira, disparo, ejeção e recuperação.
- O facão usa antecipação, cortes distintos por combo, golpe descendente e finalizador com energia.

### Pipeline

- As duas folhas 1254×1254 usam regiões explícitas para impedir cortes causados pela grade irregular.
- Testes automatizados cobrem respiração, piscada, caminhada, atraso da corrida, quatro quadros de corrida e novas poses de tiro.
- Prints oficiais ganharam registros específicos de idle, piscada, corrida e ataques de facão.

## 0.2.5 — Sprite Integration & Enemy Framing

### Sprites e ambientes

- Oito folhas transparentes novas foram copiadas para o runtime e aplicadas a arquitetura, chão, paralaxe, preenchimentos, atmosfera, moradores e objetos interativos.
- Checkpoint, porta de atalho e portão de liberação deixaram de usar formas geométricas provisórias e agora alternam sprites por estado.
- As sete salas ainda apoiadas no graybox receberam chão e fundo rasterizados sem alterar suas colisões.

### Inimigos

- Saqueador, Pistoleiro e Zé Tranca deixaram de dividir folhas irregulares como grades uniformes.
- Cada estado usado possui região explícita, escala calibrada e alinhamento dos pés independente das dimensões do quadro.
- Estados de dano e morte do Pistoleiro e de Zé Tranca receberam poses próprias.
- A validação de produção rejeita quadros que encostem no corte vertical da região.

### Capturas

- Os prints oficiais foram regenerados e ganharam `inimigos_escala_e_recorte.png`.
- O conjunto ambiental desta rodada fica em `prints_do_jogo/iteracao_0_2_5/`.

## 0.2.4 — Environmental Composition Pass

### Escala e personagens

- A escala de idle, corrida, revólver e espingarda de Nilo agora deriva da altura útil medida em cada frame e preserva uma baseline canônica.
- O multiplicador fixo usado durante o tiro foi removido.
- Nilo, Saqueador, Pistoleiro e Zé Tranca receberam proporções calibradas e sombras de contato pixeladas.

### Ambientes

- Telhados da Vila, Praça do Umbu, Barracos Queimados, Posto de Comando e Arena de Zé Tranca foram migrados para cenas editáveis de produção.
- As novas cenas combinam arquitetura completa, fundo contínuo em três planos, chão em camadas, colisões alinhadas e containers ocupado/libertado.
- A Praça ganhou Umbuzeiro central integrado à base de pedra; Barracos ganhou ruínas, entulho e VFX; Posto e Arena ganharam estruturas monumentais sem recorte involuntário.
- Arte e encontros duplicados dessas cinco salas foram removidos do decorador e do graybox procedural.

### Pipeline e validação

- Criados módulos compartilhados de paralaxe e chão para salas de 320 e 640 px.
- Validação de produção ampliada de uma para seis salas, incluindo registro, colisões, estado do mundo e exclusão de decoração duplicada.
- Adicionados guia de composição ambiental, especificação de escala visual e capturas de aceitação da iteração.
- A validação de game feel agora mede altura e baseline de Nilo nas quatro famílias de animação.

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
# Correção de chão e idle ancorado — 0.2.8

- Eliminada a faixa cinza entre a rua e o primeiro plano em todas as salas, com sobreposição segura entre sprites de solo.
- Rua das Cinzas recebeu acabamento frontal próprio para não expor o fundo abaixo da plataforma.
- Quadros parados de Nilo agora compensam o deslocamento horizontal irregular da spritesheet.
- Respiração ganhou leitura mais clara sem mover os pés; piscada e poses continuam sincronizadas.
- Teste de game feel agora também verifica a estabilidade horizontal do idle.
# Justiça e leitura de combate — 0.2.9

- Inimigos agora atacam em três fases legíveis: antecipação, momento ativo e recuperação.
- Dano corpo a corpo e disparos inimigos só nascem depois da janela de aviso.
- Aviso visual muda de amarelo para vermelho e mostra linha de mira para ataques à distância.
- Ataques fixam a direção durante a antecipação, permitindo esquiva consistente.
- Projéteis agora colidem com cenário e portões usando raycast contínuo, sem atravessar paredes em alta velocidade.
- Pistoleiros e Zé Tranca verificam linha de visão antes de iniciar disparos.
- Inimigos comuns mostram vida e postura temporariamente depois de receber dano.
- Animação do Saqueador deixou de acessar o quadro de ataque sem recorte dedicado.
- Adicionado teste automatizado de justiça de combate para fases, paredes e linha de visão.
