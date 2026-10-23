# Arquitetura

## Módulos

A app é um target fino (`Tycho/`) sobre o package local `Packages/TychoKit`, com três módulos:

- `TychoCore`: modelos SwiftData, vocabulários, ações de domínio, lógica derivada e seed. Depende só de Foundation e SwiftData.
- `TychoDesign`: tokens, tema e componentes base. Depende só de SwiftUI.
- `TychoFeatures`: ecrãs, navegação e estado de vista. Depende dos dois anteriores.

```
Tycho (app) → TychoFeatures → TychoDesign
                            → TychoCore
```

A dependência vai num só sentido. O app target importa apenas `TychoFeatures` e `TychoCore`, e `TychoCore` nunca importa SwiftUI. Sem dependências externas.

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

- A ordem usa pontos médios (`SortOrder.midpoint(before:after:)`) e renormaliza o grupo quando o intervalo fica demasiado pequeno.
- A lógica derivada é feita de funções puras: `Project.progress`, `TaskItem.progress`, `TaskItem.isOverdue(now:)` e `HomeSummary(now:)`.
- `DemoSeed` porta o seed do original (workspace Gr8r Studio, 7 projetos, 49 tarefas); `EmptySeed` cria só o workspace e o membro "me".

## Navegação e ecrãs

- `NavigationSplitView` em todas as plataformas, que no iPhone colapsa em stack.
- A rota é um `enum AppRoute` num `@Observable Router` por janela.
- Ecrãs: primeiro arranque, Home, My Tasks, Projects, Project (List e Board), inspector de tarefa, sheets de criação e Settings.
- O inspector abre em `.inspector` nos tamanhos regulares e numa sheet com detents no iPhone.
- Comandos: ⌘N nova tarefa, ⌘⇧N novo projeto, ⌘⇧L alterna light e dark, `[` alterna a sidebar e ⌘, abre as Settings.

## Design system

- Cores dinâmicas (light e dark) com os mesmos nomes dos tokens do original, mais cinco cores de status e o accent injetado por `Environment`.
- Espaçamento, raio, métricas dependentes da density, tipografia SF Pro com Dynamic Type, sombras e motion que respeita `accessibilityReduceMotion`.
- Componentes: `StatusIcon`, `PriorityIcon`, `LabelPill`, `Avatar`, `AvatarStack`, `ProgressRing`, `StatCard`, `ProjectGlyph` e `EmptyState`. Os ícones Lucide do original mapeiam para SF Symbols.
- Sidebar, toolbar e inspector usam o Liquid Glass nativo do OS 27.

## Estado e preferências

As preferências (`theme`, `accent`, `density`, `motion`) ficam em `@AppStorage`, por dispositivo e sem sincronização. A rota, a seleção e os grupos colapsados vivem no `Router` e em `@State`.

---
Anterior: [Índice](00-index.md) · Próximo: [Desenvolvimento](02-development.md)
