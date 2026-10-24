# Desenvolvimento

## Requisitos

Xcode 27, com alvos iOS 27 e macOS 27. O package usa `swift-tools-version: 6.2` e o modo de linguagem Swift 6.

## Alvos do Makefile

| Alvo | O que faz |
|---|---|
| `make test` | Corre os testes do package (`swift test` em `Packages/TychoKit`). |
| `make build` | Compila a app para macOS e para o simulador iOS, sem assinatura. |
| `make test-ui` | Corre os XCUITests de macOS: o smoke da Fase 1 e os testes das vistas Table, Calendar, Timeline e Files. |
| `make test-ios` | Corre o smoke XCUITest no simulador iOS. O simulador por omissão é `iPhone 17`; muda-se com `make test-ios SIM_NAME="iPhone 17 Pro"`. |
| `make lint` | SwiftLint e swift-format em modo estrito (`swiftlint` e `format-check`). |
| `make format` | Reescreve as fontes com o swift-format. |

## Testes de UI

Os testes de UI lançam a app com o argumento `-uiTesting`, que faz o `StoreLoader` usar um store SwiftData em memória. Cada execução começa limpa e não toca nos dados reais.

Os testes de UI usam cliques e menus de contexto, porque o XCUITest de macOS não entrega drags ao SwiftUI. Os drags do Board, do Calendar e da Timeline são cobertos pelos testes das ações e dos handlers no package, e verificados à mão. As preferências em `@AppStorage` (como a ordenação da Table) persistem entre execuções, por isso os testes não assumem o estado inicial dessas preferências.

Enquanto a automação de UI não for autorizada na máquina, `make test-ui` falha com "Timed out while enabling automation mode" e os testes só são compilados: `xcodebuild build-for-testing -scheme Tycho -destination 'platform=macOS'`. O `make test-ios` depende de um CoreSimulator atualizado.

## Referência do original

O código do Gr8r Studio vive em `~/akira-foundation/references/gr8r-studio`: `repo` com o código e `site` com o build da demo. Antes de cada consulta:

1. `git -C ~/akira-foundation/references/gr8r-studio/repo pull --ff-only`;
2. voltar a buscar o `index.html` e os `assets/` de https://gr8r-taskmanagement.vercel.app para o `site/`.

## CI

- `test.yml` (push em `main` e pull requests): o job `lint` corre em `ubuntu-latest` (actionlint, verificação de sintaxe dos scripts shell e SwiftLint); depois o job macOS, no runner `xcode-27`, corre `make format-check`, `make test` e o build para macOS. Os testes de UI e o build para iOS não correm aqui, só no nightly.
- `nightly.yml` (diário): sai cedo se não houve commits nas últimas 24 horas; caso contrário corre `make build` (macOS e simulador iOS), `make test-ios` e `make test-ui`. É o único workflow que corre os testes de UI e o build iOS.
- `branch-policy.yml`: valida o ramo de origem e o de destino de cada pull request.
- `release.yml` (tags `v*`): gera o changelog com git-cliff, publica a GitHub Release e valida o build com `xcodebuild archive` sem assinatura. A distribuição assinada fica fora da Fase 1.

Os minutos dos runners macOS são faturados a um múltiplo mais alto do que os dos Linux. Por isso o trabalho pesado fica num único job macOS por push, o nightly não corre sem commits novos e o lint corre em Linux.

---
Anterior: [Arquitetura](01-architecture.md) · [Índice](00-index.md)
