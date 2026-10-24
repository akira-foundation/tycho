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

Modelos: `Workspace`, `Member`, `Team`, `Project`, `TaskItem`, `Subtask`, `Milestone`, `CalendarEvent` e `FileRecord`. O nome `TaskItem` evita a colisão com `Task` da concorrência do Swift; a key mostrada (por exemplo `WEB-103`) deriva de `project.key` e `number`.

Regras do schema, para manter a compatibilidade com CloudKit:

- todos os atributos têm valor por omissão ou são opcionais;
- todas as relações são opcionais, com o inverso declarado num dos lados;
- nunca se usa `@Attribute(.unique)`: a unicidade é validada nas ações;
- os enums são guardados como `String` raw (`statusRaw`), com um accessor tipado, e os predicates usam o campo raw;
- cada modelo tem `id: UUID = UUID()` como identidade estável.

Vocabulários iguais ao original: `TaskStatus`, `TaskPriority`, `TaskLabel`, `ProjectStatus`, `ProjectColor` e `MemberRole`.

Na Fase 2 entraram as dependências entre tarefas (`TaskItem.blockedBy`, muitos-para-muitos consigo próprio), os milestones, os eventos e os ficheiros. O `FileRecord` guarda o conteúdo real em `data` com `@Attribute(.externalStorage)`, que no CloudKit passa a CKAsset, e `hasData` diz se há conteúdo sem carregar o blob. Ficam para as fases seguintes os comentários, a atividade, as notificações, a recorrência e as saved views.

## Fluxo das ações

As mutações passam pelas ações do `TychoCore` (`ProjectActions`, `TaskActions`, `SubtaskActions`, `DependencyActions`, `FileActions`), que recebem um `ModelContext` e um relógio injetado. Cada ação valida, muta e atualiza `updatedAt`. A ordenação da tabela vive em `TableSort`, também no `TychoCore`. As vistas leem com `@Query` e nunca escrevem diretamente, exceto bindings simples do inspector, que também passam por `TaskActions.update`.

- A ordem usa `Rank` (`Rank.swift`): `Rank.between` devolve o ponto médio entre dois vizinhos, `Rank.insert` posiciona um item entre irmãos e `Rank.appendOrder` calcula a ordem do fim do grupo. Quando o intervalo fica abaixo de `Rank.epsilon`, `Rank.insert` renormaliza o grupo em múltiplos de `Rank.step`.
- A lógica derivada é feita de funções puras: `Project.progress`, `TaskItem.progress`, `TaskItem.isOverdue(now:)` e `HomeSummary(now:)`.
- `DependencyActions` liga e desliga dependências dentro do mesmo projeto e rejeita a própria tarefa e o ciclo direto. `TaskActions.reschedule` (drop no Calendar) e `TaskActions.shift` (drag na Timeline) mexem nas datas em dias inteiros e mantêm a duração. `FileActions` acrescenta (até 250 MB), renomeia, duplica e apaga ficheiros.
- A lógica das vistas é pura e testada no Core: `CalendarGrid` e `CalendarDay` (grelha e itens do dia), `TimelineLayout`, `TimelineRows`, `DependencyPath` e `MilestoneLane` (geometria em `Double`, sem SwiftUI), `TaskComparator`, `TableColumnID` e `TableViewState` (ordenação e colunas), e `DateText` (o formatador partilhado).
- `DemoSeed` porta o seed do original (workspace Gr8r Studio, 7 projetos, 49 tarefas); `EmptySeed` cria só o workspace e o membro "me".

## Navegação e ecrãs

- `NavigationSplitView` em todas as plataformas, que no iPhone colapsa em stack.
- A rota é um `enum AppRoute` num `@Observable Router` por janela.
- Rotas do workspace: Home, My Tasks, Tasks, Calendar, Timeline e Projects, mais a de cada projeto.
- Ecrãs: primeiro arranque, Home, My Tasks, Tasks (List, Board e Table), Calendar (mês e semana), Timeline (setas de dependência e milestones), Projects, Project (Board, List, Table, Calendar, Timeline e Files), inspector de tarefa (com "Blocked by" e "Attachments"), sheets de criação e Settings.
- O `Router` guarda também o estado partilhado do Calendar (data e modo) e da Timeline (zoom e agrupamento).
- Na vista Files os ficheiros chegam por picker ou drop e a pré-visualização usa Quick Look sobre uma cópia temporária, apagada ao fechar. A app é sandboxed e só pede o entitlement de ficheiros escolhidos pelo utilizador em leitura.
- O detalhe da tarefa usa `.inspector(...)` com `inspectorColumnWidth`; em largura compacta (iPhone) o SwiftUI apresenta-o como sheet.
- Comandos: ⌘N nova tarefa, ⌘⇧N novo projeto, ⌘⇧L alterna light e dark, ⌘, abre as Settings. A sidebar alterna pelo `SidebarCommands()` do sistema (⌃⌘S).

## Design system

- Cores dinâmicas (light e dark) com os mesmos nomes dos tokens do original, mais cinco cores de status e o accent do sistema (`Color.accentColor`), sem preferência própria.
- Espaçamento, raio, métricas dependentes da density, tipografia SF Pro com Dynamic Type, sombras e motion que respeita `accessibilityReduceMotion`.
- Componentes: `StatusIcon`, `PriorityIcon`, `LabelPill`, `Avatar`, `AvatarStack`, `ProgressRing`, `StatCard`, `ProjectGlyph` e `EmptyState`. Os ícones Lucide do original mapeiam para SF Symbols.
- Sidebar, toolbar e inspector usam o Liquid Glass nativo do OS 27.

## Estado e preferências

As preferências (`theme`, `density`, `motion`, `weekStart` e `dateFormat`) ficam em `@AppStorage`, por dispositivo e sem sincronização; nas Settings aparecem como "Start week on" e "Date format", e chegam às vistas pelo `Environment` (`\.weekStart` e `\.dateText`). O estado de cada Table (ordenação, colunas escondidas e larguras) fica em `@AppStorage("table.views")`, por chave (`p:<id>` e `tasks`). A rota, a seleção e os grupos colapsados vivem no `Router` e em `@State`.

---
Anterior: [Índice](00-index.md) · Próximo: [Desenvolvimento](02-development.md)
