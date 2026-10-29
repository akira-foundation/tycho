# Tycho (agents)

Port nativo em SwiftUI (iOS 27 e macOS 27) do Gr8r Studio. App de uso pessoal e local. A colaboração vem numa fase posterior.

## Referência do original

- Código: `~/akira-foundation/references/gr8r-studio/repo`
- Build da demo: `~/akira-foundation/references/gr8r-studio/site`
- Antes de cada consulta: `git -C ~/akira-foundation/references/gr8r-studio/repo pull --ff-only`, e voltar a buscar o `index.html` e os `assets/` de https://gr8r-taskmanagement.vercel.app para o `site/`.
- Segue-se a UI e os princípios do original. Tudo nativo, sem webviews.

## Estrutura

- `Tycho/`: app target fino (cenas e container).
- `Packages/TychoKit`: `TychoCore` (SwiftData, ações, lógica pura das vistas em `Schedule/` e `Table/`, datas em `Dates/`, seed), `TychoDesign` (tokens e componentes, só SwiftUI) e `TychoFeatures` (ecrãs, uma pasta por vista: `Table/`, `Calendar/`, `Timeline/`, `Files/`, `Workspace/`). A dependência vai num só sentido: Features → Design e Core.
- As mutações passam pelas ações do `TychoCore`. As vistas leem com `@Query`.

## Schema (pronto para CloudKit)

Atributos com default ou opcionais, relações opcionais com inverso, nunca `.unique`, enums como `String` raw.

## Capacidades e testes de UI

- A app é sandboxed e pede só o entitlement de ficheiros escolhidos pelo utilizador em leitura (`ENABLE_USER_SELECTED_FILES = readonly`), para o picker e o drop da vista Files.
- Os XCUITests só compilam até a automação de UI estar autorizada; valida-se com `xcodebuild build-for-testing -scheme Tycho -destination platform=macOS`.

## Comandos

- `make test`: testes do package (Swift Testing).
- `make build`: build da app para macOS e para o simulador iOS.
- `make test-ui`: XCUITests de macOS (smoke e vistas).
- `make test-ios`: smoke XCUITest no simulador iOS; `SIM_NAME` escolhe o simulador (por omissão `iPhone 17`).
- `make lint`: SwiftLint e swift-format em modo estrito.
- `make format`: aplica o swift-format.
