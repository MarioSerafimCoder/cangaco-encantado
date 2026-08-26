# Cangaço Encantado — Iteração 0.2.6

## Nilo Animation Upgrade

As folhas `nilo_locomocao_0_2_6.png` e `nilo_combate_0_2_6.png` substituem os sprites provisórios do herói. A versão integrada possui margem transparente de segurança em cada célula: locomoção com 985×997 px e combate com 956×992 px. Cada pose recebe região explícita, altura de referência e ponto inferior próprio. A baseline continua em 12 px abaixo da origem física do personagem.

## Locomoção

- Idle: três poses abertas formam o ciclo de respiração; uma quarta pose fecha os olhos durante 0,15 s a cada 4,8 s.
- Caminhada: quatro poses enquanto o botão permanece pressionado por menos de 2 segundos.
- Corrida: quatro poses e velocidade máxima depois de 2 segundos mantendo a mesma direção.
- Soltar, agachar, bloquear o movimento ou inverter a direção reinicia o contador.
- Morte: quatro poses progressivas da queda.

## Combate

- Pistola: disparo semiautomático, oito munições e quatro poses de mira, clarão, fumaça e recuperação.
- Rifle: disparo preciso de longo alcance, quatro munições, maior dano de postura e quatro poses próprias.
- Facão: antecipação, combo de três golpes e variantes para cima e para baixo usando a terceira linha.
- Especial: golpe amplo de 4 de dano e 6 de postura, animado pela quarta linha e limitado por recarga de 5 segundos.
- Escala e baseline são normalizadas entre locomoção e combate.

## Validação

`game_feel_validation.tscn` verifica a janela de piscada, as poses de respiração, caminhada, ativação da corrida somente após 2 segundos, contatos dos pés, pistola semiautomática, rifle e os quatro quadros do especial. `room_production_validation.tscn` verifica os limites e as margens verticais das 32 regiões do herói.
