# Changelog

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
