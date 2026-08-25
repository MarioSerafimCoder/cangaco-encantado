# Sprites ambientais corrigidos — primeira parte

Pacote de estruturas, ambientes e obstáculos para as 13 áreas da Vila do Umbuzeiro.

## Estado atual

Os oito arquivos foram devolvidos com transparência RGBA real, validados sem alteração de nome ou canvas e integrados ao jogo. Esta pasta permanece como fonte corrigida para futuras revisões; a cópia usada em tempo de execução fica em `assets/environments/vila_umbuzeiro/atlases/`.

## Regras para futuras revisões

- Remova somente o fundo verde.
- Exporte como PNG RGBA com transparência real.
- Não use corte automático do canvas.
- Não redimensione nem reposicione os elementos.
- Preserve o nome e as dimensões de cada arquivo.
- Deixe os arquivos corrigidos nesta mesma pasta e avise quando terminar.

O verde pode produzir pequenos halos nas bordas. Remova também os pixels verdes sem apagar os contornos escuros dos sprites.

## Cobertura das salas

| Arquivo | Áreas atendidas | Conteúdo principal |
|---|---|---|
| `01_casa_nilo_e_rua_props.png` | 01 Casa de Nilo; 02 Rua das Cinzas | casa, porta, janela, cama, mesa, caixas, carroça, cercas e barricada |
| `02_igreja_velha_e_checkpoint.png` | 03 Igreja Velha | igreja, checkpoint, altar, bancos, cruz, velas, entulho e portão |
| `03_telhados_e_praca_umbu.png` | 04 Telhados; 05 Praça do Umbu | telhados-plataforma, chaminé, umbuzeiro, banco, barraca e degrau |
| `04_barracos_queimados.png` | 06 Barracos Queimados | barracos destruídos, portal, vigas, cerca, barril, fogueira e defesa |
| `05_armazem_e_patio.png` | 07 Armazém; 08 Pátio | fachada, passarelas, doca, caixas, gancho, barris, carro e barricada |
| `06_beco_e_poco_romaozinho.png` | 09 Beco; 10 Poço | paredes estreitas, varal, sacada, poço, espinhos, cactos, escada e potes |
| `07_barricada_e_posto_comando.png` | 11 Barricada; 12 Posto | portões, posto, torre, bandeira, estacas, sacos, suprimentos e pilares |
| `08_arena_ze_tranca.png` | 13 Arena de Zé Tranca | portão, postes, arquibancada, barricada, braseiro, entulho, plataforma e gancho |

## Dimensões

| Arquivo | Canvas |
|---|---|
| `01_casa_nilo_e_rua_props.png` | 1672x941 |
| `02_igreja_velha_e_checkpoint.png` | 1659x948 |
| `03_telhados_e_praca_umbu.png` | 1536x1024 |
| `04_barracos_queimados.png` | 1536x1024 |
| `05_armazem_e_patio.png` | 1536x1024 |
| `06_beco_e_poco_romaozinho.png` | 1536x1024 |
| `07_barricada_e_posto_comando.png` | 1717x916 |
| `08_arena_ze_tranca.png` | 1536x1024 |

O jogo consome regiões dos atlas diretamente, sem recortar ou modificar os PNGs originais. O posicionamento das regiões está centralizado em `scripts/world/vila_art_decorator.gd`.
