# Arquitetura

## Módulos

A app é um target fino (`Tycho/`) sobre o package local `Packages/TychoKit`, com três módulos:

- `TychoCore`: modelos SwiftData, vocabulários, ações de domínio, lógica derivada e seed. Depende só de Foundation e SwiftData.
- `TychoDesign`: tokens, tema e componentes base. Depende só de SwiftUI e das frameworks da plataforma (CoreGraphics, AppKit, UIKit), nunca de `TychoCore`.
- `TychoFeatures`: ecrãs, navegação e estado de vista. Depende dos dois anteriores.

```
Tycho (app) → TychoFeatures → TychoDesign
                            → TychoCore

TychoDesign e TychoCore não dependem um do outro
```

A dependência vai num só sentido. O app target importa `TychoFeatures` (e SwiftUI), e `TychoCore` nunca importa SwiftUI. Sem dependências externas.

## Modelo de dados

Modelos: `Workspace`, `Member`, `Team`, `Project`, `TaskItem` e `Subtask`. O nome `TaskItem` evita a colisão com `Task` da concorrência do Swift; a key mostrada (por exemplo `WEB-103`) deriva de `project.key` e `number`.

Regras do schema, para manter a compatibilidade com CloudKit:

- todos os atributos têm valor por omissão ou são opcionais;
- todas as relações são opcionais, com o inverso declarado num dos lados;
- nunca se usa `@Attribute(.unique)`: a unicidade é validada nas ações;
- os enums são guardados como `String` raw (`statusRaw`), com um accessor tipado, e os predicates usam o campo raw;
- cada modelo tem `id: UUID = UUID()` como identidade estável.

Vocabulários iguais ao original: `TaskStatus`, `TaskPriority`, `TaskLabel`, `ProjectStatus`, `ProjectColor` e `MemberRole`.

Ficam fora da Fase 1: dependências entre tarefas, anexos, comentários, atividade, notificações, milestones, recorrência e saved views. Entram como atributos opcionais ou modelos novos, com migração lightweight.

## Fluxo das ações

As mutações passam pelas ações do `TychoCore` (`ProjectActions`, `TaskActions`, `SubtaskActions`), que recebem um `ModelContext` e um relógio injetado. Cada ação valida, muta e atualiza `updatedAt`. As vistas leem com `@Query` e nunca escrevem diretamente, exceto bindings simples do inspector, que também passam por `TaskActions.update`.

- A ordem usa `Rank` (`Rank.swift`): `Rank.between` devolve o ponto médio entre dois vizinhos, `Rank.insert` posiciona um item entre irmãos e `Rank.appendOrder` calcula a ordem do fim do grupo. Quando o intervalo fica abaixo de `Rank.epsilon`, `Rank.insert` renormaliza o grupo em múltiplos de `Rank.step`.
- A lógica derivada é feita de funções puras: `Project.progress`, `TaskItem.progress`, `TaskItem.isOverdue(now:)` e `HomeSummary(now:)`.
- `DemoSeed` porta o seed do original (workspace Gr8r Studio, 7 projetos, 49 tarefas); `EmptySeed` cria só o workspace e o membro "me".

## Navegação e ecrãs

- `NavigationSplitView` em todas as plataformas, que no iPhone colapsa em stack.
- A rota é um `enum AppRoute` num `@Observable Router` por janela.
- Ecrãs: primeiro arranque, Home, My Tasks, Projects, Project (List e Board), inspector de tarefa, sheets de criação e Settings.
- O detalhe da tarefa usa `.inspector(...)` com `inspectorColumnWidth`; em largura compacta (iPhone) o SwiftUI apresenta-o como sheet.
- Comandos: ⌘N nova tarefa, ⌘⇧N novo projeto, ⌘⇧L alterna light e dark, ⌘, abre as Settings. A sidebar alterna pelo `SidebarCommands()` do sistema (⌃⌘S).

## Design system

- Cores dinâmicas (light e dark) com os mesmos nomes dos tokens do original, mais cinco cores de status e o accent injetado por `Environment`.
- Espaçamento, raio, métricas dependentes da density, tipografia SF Pro com Dynamic Type, sombras e motion que respeita `accessibilityReduceMotion`.
- Componentes: `StatusIcon`, `PriorityIcon`, `LabelPill`, `Avatar`, `AvatarStack`, `ProgressRing`, `StatCard`, `ProjectGlyph` e `EmptyState`. Os ícones Lucide do original mapeiam para SF Symbols.
- Sidebar, toolbar e inspector usam o Liquid Glass nativo do OS 27.

## Estado e preferências

As preferências (`theme`, `accent`, `density`, `motion`) ficam em `@AppStorage`, por dispositivo e sem sincronização. A rota, a seleção e os grupos colapsados vivem no `Router` e em `@State`.

---
Anterior: [Índice](00-index.md) · Próximo: [Desenvolvimento](02-development.md)
