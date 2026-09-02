# Avaliação de cobertura de sprites do mapa

Auditoria feita sobre os prints oficiais das 13 áreas, as cenas de produção e os elementos desenhados por código.

## Cobertura por área

| Área | Cobertura disponível após as oito folhas |
|---|---|
| 01 Casa de Nilo | casas completas, limite de rua, chão, serras e atmosfera |
| 02 Rua das Cinzas | já produzida; atmosfera complementar disponível |
| 03 Igreja Velha | ala da igreja, cemitério, chão, checkpoint em dois estados e fundo |
| 04 Telhados | fachadas completas, fundações, chão e fundo |
| 05 Praça do Umbu | casas laterais, chão de pedra, moradores chibi e atmosfera |
| 06 Barracos | ruína completa, solo queimado, vila danificada e preenchimento |
| 07 Armazém | ala completa, doca, suprimentos, chão e fundo |
| 08 Pátio | estruturas sustentadas, conjuntos de carga, chão e fundo |
| 09 Beco | casas/arco completos, paredes conectadas, chão e fundo |
| 10 Poço | composição do poço, caatinga, transições, chão e fundo |
| 11 Barricada | portões, torre, bloqueios em estados e horizonte fortificado |
| 12 Posto | arquitetura militar, terreno e atmosfera complementar |
| 13 Arena | já produzida; portões e estados visuais complementares disponíveis |

## Lacunas encontradas nesta auditoria

1. Os moradores libertados da Praça ainda usam o spritesheet-base de Nilo com modulação de cor.
2. O checkpoint da Igreja ainda é desenhado como círculo e cruz por `_draw()`.
3. A porta de atalho ainda é um retângulo colorido com maçaneta circular.
4. Os portões de liberação/barricada ainda usam retângulos e texto técnico no mundo.

As folhas `07_moradores_chibi_da_vila.png` e `08_objetos_interativos_e_estados.png` foram geradas para fechar essas lacunas.

## Conclusão

Não foi identificada outra categoria indispensável de sprite de mapa. Após remover o fundo das oito folhas, o trabalho restante é integração: recortar regiões, migrar as sete salas ainda procedurais, substituir placeholders e regenerar os prints. Sombras, tints de estado, colisões e efeitos rápidos podem continuar procedurais porque não representam arquitetura ou objetos do mapa.

