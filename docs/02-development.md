# Desenvolvimento

## Requisitos

Xcode 27, com alvos iOS 27 e macOS 27. O package usa `swift-tools-version: 6.2` e o modo de linguagem Swift 6.

## Alvos do Makefile

| Alvo | O que faz |
|---|---|
| `make test` | Corre os testes do package (`swift test` em `Packages/TychoKit`). |
| `make build` | Compila a app para macOS e para o simulador iOS, sem assinatura. |
| `make test-ui` | Corre o smoke XCUITest em macOS. |
| `make test-ios` | Corre o smoke XCUITest no simulador iOS. O simulador por omissão é `iPhone 17`; muda-se com `make test-ios SIM_NAME="iPhone 17 Pro"`. |
| `make lint` | SwiftLint e swift-format em modo estrito (`swiftlint` e `format-check`). |
| `make format` | Reescreve as fontes com o swift-format. |

## Testes de UI

Os testes de UI lançam a app com o argumento `-uiTesting`, que faz o `StoreLoader` usar um store SwiftData em memória. Cada execução começa limpa e não toca nos dados reais.

## Referência do original

O código do Gr8r Studio vive em `~/akira-foundation/references/gr8r-studio`: `repo` com o código e `site` com o build da demo. Antes de cada consulta:

1. `git -C ~/akira-foundation/references/gr8r-studio/repo pull --ff-only`;
2. voltar a buscar o `index.html` e os `assets/` de https://gr8r-taskmanagement.vercel.app para o `site/`.

## CI

- `test.yml` (push em `main` e pull requests): lint dos workflows e do Swift num runner Linux, e depois formatação, `make test` e build macOS no runner `xcode-27`.
- `nightly.yml` (diário): sai cedo se não houve commits nas últimas 24 horas; caso contrário corre `make build`, `make test-ios` e `make test-ui`.
- `branch-policy.yml`: valida o ramo de origem e o de destino de cada pull request.
- `release.yml` (tags `v*`): gera o changelog com git-cliff, publica a GitHub Release e valida o build com `xcodebuild archive` sem assinatura. A distribuição assinada fica fora da Fase 1.

Os runners macOS gastam minutos a um múltiplo do preço dos Linux (10x no GitHub-hosted). Por isso o trabalho pesado fica num único job macOS por push, o nightly não corre sem commits novos e o lint corre em Linux.

---
Anterior: [Arquitetura](01-architecture.md) · [Índice](00-index.md)
