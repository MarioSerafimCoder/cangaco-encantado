# Pacote de sprites — polimento da experiência inicial

Gerado em 01/09/2026 com a ferramenta integrada de geração de imagens, usando prints atuais do jogo apenas como referência de estilo, escala, materiais e iluminação.

Todos os atlas possuem fundo branco e peças separadas por margens para facilitar a remoção do fundo e o recorte individual.

## Arquivos

### 01_telhados_atlas_fundo_branco.png

- Quatro fachadas com alturas e larguras diferentes.
- Dois telhados quebrados.
- Beirais modulares.
- Vigas, pilares e suportes diagonais.
- Sacada e varanda modular.

Prompt final: atlas ortográfico de arquitetura modular para Telhados da Vila, em pixel art compatível com o jogo, com fachadas completas, coberturas destruídas e peças estruturais isoladas sobre branco puro.

### 02_igreja_cemiterio_atlas_fundo_branco.png

- Muro de cemitério reto, canto, terminal e trecho destruído.
- Portão de ferro com pilares.
- Três túmulos diferentes.
- Parede lateral e contrafortes da igreja.

Prompt final: atlas ortográfico para igreja e cemitério, com alvenaria externa clara, ferro envelhecido, lápides e contrafortes modulares, sem aparência de peças subterrâneas.

### 03_praca_atlas_fundo_branco.png

- Umbuzeiro-landmark com banco circular integrado.
- Banco de madeira e pedra.
- Barraca de mercado variante 02.

Prompt final: atlas de elementos centrais da Praça do Umbu, com umbuzeiro monumental, mobiliário e barraca comercial alternativa em pixel art do sertão.

### 04_vila_baixa_rua_atlas_fundo_branco.png

- Duas casas populares.
- Tapumes retos, cantos e trechos destruídos.
- Porta e janela barricadas.
- Paredes quebradas, cantos, reboco exposto e bases de pedra.

Prompt final: atlas de arquitetura popular e ruínas reutilizáveis para Vila Baixa e Rua das Cinzas, com construção humilde, madeira improvisada e módulos de dano isolados.

### 05_ambiental_encantado_atlas_fundo_branco.png

- Pegadas, fuligem, marca de roda, rachadura, mancha e escombros.
- Três vegetações secas pequenas.
- Duas variações de raízes em alvenaria.
- Duas formações rochosas menores.
- Cinco fragmentos rúnicos e uma composição circular quebrada.

Prompt final: atlas de pequenos elementos ambientais para exteriores, subterrâneo, cavernas e santuário, com decals irregulares, vegetação seca, raízes, rochas e runas de brilho contido.

### 06_telhados_fachadas_suplemento_fundo_branco.png

- Quatro fachadas adicionais com silhuetas e alturas bem diferentes.
- Casa estreita de três pisos, oficina com varanda, torre danificada e casa assimétrica.

Prompt final: complemento arquitetônico vertical para Telhados, com superfícies de telhado utilizáveis como plataformas e fachadas completas isoladas.

### 07_vila_baixa_casas_pequenas_suplemento_fundo_branco.png

- Quatro casas populares realmente pequenas, todas de um piso.
- Variações de adobe, pedra, madeira improvisada e telhado reparado.

Prompt final: conjunto de moradias compactas e humildes para diferenciar a Vila Baixa sem reutilizar casas grandes.

### 08_decals_vegetacao_rochas_suplemento_fundo_branco.png

- Marcas longas de roda de carroça sem a roda.
- Manchas de fuligem.
- Vegetação seca de caatinga.
- Duas formações rochosas pequenas.
- Três grupos de escombros.

Prompt final: correção dos elementos ambientais interpretados incorretamente no primeiro atlas, mantendo somente objetos pequenos e reutilizáveis.

### 09_rachaduras_chao_suplemento_fundo_branco.png

- Seis rachaduras secas ramificadas utilizáveis.
- Duas variações compactas adicionais que podem ser descartadas caso pareçam pavimentação apó o recorte.

Prompt final: decals exclusivos de fissuras e rachaduras de terra seca, sem objetos de cena, destinados a sobreposição no piso existente.

### 10_nilo_aquisicao_reacao_fundo_branco.png

- Quatro poses de aquisição de habilidade.
- Quatro poses de reação à presença do Encantado.
- Mesmo Nilo das folhas de locomoção e combate, sem armas, texto ou símbolos de pontuação.

Prompt final: folha 2×4 de Nilo em pixel art, com aquisição do Passo da Pedra na linha superior e reação sobrenatural contida na linha inferior, em branco puro. Uma edição final removeu os símbolos `!?` gerados na primeira versão sem alterar as oito poses.

## Preparação recomendada

1. Remover apenas o branco exterior, preservando os vazios internos de cada peça quando necessário.
2. Recortar cada elemento em arquivo próprio, mantendo alguns pixels de margem.
3. Exportar em PNG com transparência real.
4. Não redimensionar com filtro linear; usar interpolação por vizinho mais próximo.
5. Enviar os arquivos recortados mantendo os nomes por grupo para aplicação automática no projeto.
