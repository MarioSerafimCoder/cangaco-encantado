# Sprites pendentes — passe 0.2.5

Estas folhas foram geradas com fundo branco para remoção manual. Não estão integradas ao runtime ainda.

## Arquivos

### 01_arquitetura_civil_casas_igreja_beco.png

Seis estruturas completas:

1. casa térrea;
2. sobrado estreito;
3. casa de esquina;
4. ala lateral da igreja;
5. arco de ligação do beco;
6. casa baixa em ruínas.

Uso principal: Casa de Nilo, Igreja Velha, Beco dos Saqueadores e Poço do Romãozinho.

### 02_arquitetura_armazem_patio_barricada.png

Seis estruturas industriais/militares:

1. ala completa do armazém;
2. doca coberta e sustentada;
3. checkpoint fortificado com passagem;
4. torre de vigia completa;
5. abrigo de suprimentos;
6. portão de transição militar.

Uso principal: Armazém Tomado, Pátio do Armazém e Barricada da Companhia.

### 03_sistema_de_chao_e_transicoes.png

Oito módulos de terreno:

1. terra seca;
2. rua de terra batida clara;
3. pedra de praça;
4. solo queimado;
5. solo militar com metal;
6. fundação de edifício;
7. transição inclinada esquerda;
8. transição inclinada direita.

Uso: substituir os retângulos marrons procedurais e integrar edifícios ao chão.

### 04_parallax_serras_e_vila_distante.png

Seis faixas de paralaxe:

1. serras suaves com mesas;
2. serras rochosas;
3. horizonte de caatinga;
4. vila preservada;
5. vila danificada;
6. arredores fortificados.

Uso: eliminar montanhas poligonais e black gaps das sete salas ainda não migradas.

### 05_conjuntos_de_transicao_e_preenchimento.png

Oito composições prontas:

1. limite de casa e rua;
2. limite do cemitério/igreja;
3. pátio coberto com caixas;
4. carroça, barris e cerca;
5. ruínas ligadas por varal;
6. conjunto do poço e caatinga;
7. lateral de bloqueio militar;
8. entrada de rua em adobe.

Uso: preencher vazios com relações espaciais coerentes, sem espalhar props aleatórios.

### 06_elementos_atmosfericos.png

Nuvens, sol, poeira, fumaça distante, aves e névoa horizontal em sprites separados.

Uso: substituir círculos, linhas e efeitos atmosféricos procedurais nas salas restantes.

### 07_moradores_chibi_da_vila.png

Oito moradores distintos: idosa, idoso, artesã, agricultor, adolescente, criança, comerciante e cuidador da igreja.

Uso: substituir os três moradores provisórios da Praça que atualmente reutilizam frames e proporções de Nilo.

### 08_objetos_interativos_e_estados.png

Quatro pares de estado:

1. checkpoint inativo/ativo;
2. porta de atalho fechada/aberta;
3. portão de liberação bloqueado/aberto;
4. barricada fechada/desmontada.

Uso: substituir os círculos, linhas e retângulos de `Checkpoint`, `ShortcutDoor` e `LiberationGate`.

## Procedimento depois da remoção do fundo

1. Preserve o tamanho original de cada PNG.
2. Apague apenas o branco externo; mantenha brancos e brilhos que pertençam aos sprites.
3. Exporte em PNG RGBA.
4. Não recorte a folha nem mova os elementos internamente.
5. Avise que as oito folhas estão corrigidas para iniciar o recorte em `AtlasTexture` e a migração das salas 01, 03 e 07–11.

## Direção visual usada

As folhas existentes da Vila e da Rua das Cinzas foram usadas somente como referência de estilo. Os novos sprites seguem pixel art lateral, paleta quente do sertão, contornos escuros, materiais envelhecidos e estruturas arquitetonicamente completas.
