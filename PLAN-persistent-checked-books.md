# Persistent checked-book snapshots

## Context

**Bend requires persistent checked states whose durability and sharing are properties of the compiler representation, not properties added by a cache wrapper.** The current `book_read` API exposes shallow seeds: term graphs remain mutable, HOAS closures are not a durable format, and suffix checking still traverses the old declaration order. The implementation must support immutable parents, bounded manifests, incrementally encoded shared chunks, authenticated restoration, exact loader state, and check-only operation.

**The work splits across two repositories.** This fork supplies the checker capability: immutable, resumable checked states and the hooks a persistence layer needs, inside the existing token caps. The persistence layer lives downstream in `bend-proof-of-compile`, an existing content-addressed partial compiler whose rule is that all semantics (keys, invalidation, plans) live in Bend and TypeScript is only a capability host. PR #1 (`book_read(file, unsafe_seed)`, the `BookState` API) is what the downstream consumes today; it is retired once the downstream moves to the new capability.

**Private proofs remain external development inputs.** Use the local `bend-categories` checkout only through a supplied fixture path. Do not commit its sources, proof-derived artifacts, or checkpoints. Public regression cases must be independently constructed.

## Decisions

| # | Decision | Outcome | Why |
|---|---|---|---|
| U1 | What a law's declaration sees of its later fill | **Keep cold semantics.** A fill's `i` (foreign) and `u` (`@unsafe`) land on the law's record at parse time and are visible at the declaration event (`bend.ts:2567`, `2575–2584`, `3920`, `3930`). A file boundary is sealed only if no law declared at or before it has a later fill carrying `i` or `u`; otherwise the batch extends. | `AGENTS.md` requires preserving language semantics. Not a soundness hole (a foreign fill has no Bend body; unfilled laws still count open; reliance is reported). Exposure: 0 of 1498 public inputs for `i`, 1 for `u` (`tests/check/unsafe_many.bend`, documented); 0 in the private workload, whose output is identical under a declaration-only prototype. |
| U2 | What durable states store | **Types and bodies, not elaborations.** Each definition's lowered type and body, ADT and constructor types, instance types and bodies with the instance table, per-definition reporting summaries, obligations, and source pages. They are lowered when a boundary is sealed, never on the check path. Restore decodes only the definitions a check touches; compilation re-elaborates what `main` reaches. | Chosen by the user. Lowering then raising is idempotent on committed types and bodies (verified on 76,730 types and 53,710 bodies), so the kernel needs no retention hook. Elaborations are excluded because lowering them is exponential on typed let chains and costs 25–82% of check CPU on parse-heavy inputs. |
| U4 | Code growth | **The persistence layer lives in `bend-proof-of-compile`.** In this fork, `bend2/bend.ts` stays ≤ 43,000 tokens and `comp.ts` ≤ 65,000. | Chosen by the user. Exact counts (the `ttok` tokenizer): `bend.ts` 42,979 (21 tokens of headroom), `comp.ts` 64,958 (42), `main.ts` 7,295 (2,705). Kernel changes must be paid for by compaction in the same file. |
| U6 | What an extension's parent may be | **A resumption point of one entry's cold load traversal.** The next file checked must be the next file of the entry's cold traversal, at the loader's namespace. | Only states the cold checker reaches; today's `--checkup` seeding accepts a file a cold check rejects (a helper matching `True{}` before `import Base`). |
| U7 | PR #1's `unsafe_seed` and `--checkup` seeding | **Retire `unsafe_seed` once the downstream has moved to the resume capability; fix `--checkup` now** to seed from an immutable Base parent only when Base is the first file loaded. | No current public test imports Base after another module, so the fix changes no public verdict. |
| — | Downstream repository | **`bend-proof-of-compile`** (`/Users/timpierson/Work/bend-proof-of-compile`). | Named by the user. |

## Open decisions

| # | Decision | Options | Recommendation | Blocks |
|---|---|---|---|---|
| U3 | Lean scope | Keep every law blocking; or keep design-level laws (resumption equivalence under U1's rule, old-root preservation, extension composition) and test codecs and indexes. | Design-level laws | Acceptance |
| U5 | Who may write the store | (a) Single user: no signature; roots are trusted because only this user writes the store (a stated relaxation of "authenticated restoration"). (b) Stores crossing a trust boundary, such as CI caches: Ed25519, with the private key only in a check-only signer process that never evaluates program code. HMAC is unsuitable: verifying requires the key, and the process holding it runs checked programs (`comp.ts:1318`). The downstream's Merkle keys prove which inputs a state claims, not that the checker produced it. | State the threat model; (b) if any root crosses a trust boundary | Downstream trust work |
| U8 | Two import parsers | The downstream's `bend/Source.bend` re-implements the kernel's import grammar in Bend, and its `Graph.bend` re-derives the load order. A disagreement with `book_load` (comments in the header, `0x` hub paths, `.bend` checks, path normalization, realpaths) would checkpoint prefixes the checker never reaches. (a) The kernel exposes its resolved traversal (steps as data), and the Bend application computes keys from those steps. (b) Keep `Source.bend` and add a conformance lane against the kernel's traversal. | (a): one import parser. It is the compiler reporting what it loaded, not the host deciding semantics. | Downstream key work |

## Findings about the downstream MVP

These come from reading `bend-proof-of-compile` at `deb3297` against round-2 evidence, and they are the downstream work's starting points.

- **F1. Restored elaborations can compile differently from cold.** The codec stores `e` as `term_lower(term_higher(e))` (`src/codec.ts:77`, `243–244`) and restores it as the definition's `e`, which the compiler raises with `term_higher` (`comp.ts:1419`). Annotation types contain checker variables `Var(k, i ≥ 0)` that `term_higher` with an empty environment turns into global references (`bend.ts:722–726`). A round-2 probe (a recursive polymorphic definition instantiated at `List<&2, U32>`) produced different C from such a raise, and the binary faulted. Lowering is also exponential on typed let chains: 24 lets need more than 30 GB. U2 removes stored elaborations.
- **F2. Every extension copies the whole parent book** (`cloneCheckedBook`, the same shape as `book_seed`) and replays its events through `book_valid(book, done)`'s install path.
- **F3. Extension by file plus caller-computed namespace** is a U6 resumption only if `Graph.bend`'s order and namespaces equal the loader's (U8).
- **F5. Every step is judged for open work** (`bookReadAtNamespace`, `holes = book.hols + book.open` per step): a law declared in one file and filled in a later one leaves the earlier step open, so the MVP rejects a program the cold check accepts (`bend A.bend` prints `7n`; `poc build A.bend` fails with `1 TODO found`). The spec's F8.
- **F4. The reported speedup is 2.2×** (67 s incremental versus 148 s cold, wall time, on a shared host). Gate M puts the private workload's entry file at 4.9% of check CPU, so decode, raise and validation overhead, not checking, likely dominates. The downstream migration measures this.

## Approach

**A checked state is a resumption point of one cold load traversal.** Extension checks the next files of the same traversal against an immutable parent. Parsing reads only declaration shape, and imports are parsed before their importers, so checking file by file observes what parse-all observes, except for U1's leak, which the sealing rule handles.

**Parents are immutable by construction, and extension is O(1).** A child's tables are overlays whose prototype is the parent's tables; a law's fill copies the law's record instead of mutating it; instance tables number over inherited entries. HOAS term objects are shared: after commit, only elaboration cells are ever written (`term_wnf`'s write-back, `bend.ts:3029–3031`), and freezing 35M committed type and body objects across the public corpus produced zero writes. Elaborations are shared only below parents with no open obligations; otherwise they are rebuilt per compile.

**Durability stores what the parser already built (U2).** Keeping the parser's raw type syntax and lowered bodies costs nothing on the check path; restoration raises them with the same `term_higher` calls the parser made, lazily, per touched definition.

**Measurement decides, and failures route to named remedies** (Gate M).

### Confirmed decisions

- **Checked prefixes may contain explicit unfilled law declarations, but never unresolved holes.** Every judgment inside such a prefix is one the cold run already makes; only publishing the prefix is new. The incomplete-work message keeps cold's single count of holes plus open laws (`tests/snapshot/open_laws_count.bend`).
- **Synchronous local reads** of stored states during operations.
- **Mechanically checked laws and executable conformance jointly gate migration** (scope per U3).
- **Restored roots require trusted-producer provenance** (mechanism per U5).
- **Peak resident memory ≤ 3× the completed plain check-only baseline**, with structural counters: the ceiling does not excuse whole-book copies.

## In-repo work: the checker capability

Line references identify revision `163230d1`. Every change is behavior-preserving for cold checks except where stated. All changes in `bend.ts` and `comp.ts` are paid for by behavior-preserving compaction in the same file, verified by the full public sweep.

### K1. A fill copies the law's record.

`parse_def` reuses the law's record and mutates `n`, `u`, `i` and `v` (`2556–2588`). It instead installs a copy (`{ ...law }`) and mutates that. `book_valid` already builds the declaration view from the latest record (`dec = { ...tld, v: null }`, `3920`), so cold semantics, including U1's leak, are unchanged, and a parent's record is never written.

### K2. Validation resumes over an immutable parent.

`book_valid(book, done)` resets `tlds` and `ctrs`, re-installs every prefix record and scans every event (`3860–3947`). When the book's tables are overlays over a parent, validation instead:
- starts a fresh overlay over the same parent;
- computes `last` over the new events only;
- reveals only new events;
- installs no prefix record.

The cold path (`done = 0`, no parent) is unchanged. Holes and open laws count the parent's obligations still open plus the batch's.

### K3. Instance tables over a parent.

`def_inst` numbers instances by `Object.keys(is).length` (`3823`) and writes into `book.tmps` (`3817`). A child book copies the parent's per-template instance tables (string maps, not definition records), so numbering continues and the parent's tables are never written; no kernel change is needed. A failed instantiation leaves nothing in the parent, because the failed child is discarded.

`def_check`'s overlay shares `tmps` safely only because `term_infer` never mints while checking a template body (`3385`). That invariant is stated at the guard and covered by `tests/snapshot/template_in_template_closed.bend`.

### K3b. A child counts its parent's open work.

`book_over` copies the parent's `hols` and `open`, and `book_valid` takes back the parent's count for an open law whose name the child's events touch (the child's last event for it counts it again if it stays open), so `hols + open` of a child is the cold TODO count. Without it, a child of a parent with an open law or a hole checked clean where cold fails; `163230d1`'s seeded path had the same gap. Commit `80ffd6d1`.

### K4. Enumerations see inherited names.

The compiler and the report read tables as own properties (`comp.ts:1225`, `1436`, `1442`, `2859`; `main.ts:509`). A child book is flattened once, parent's names first, before it is run, compiled or reported (`book_flat` in `main.ts`), which reproduces a cold book's key order; `comp.ts` is unchanged.

### K5. Stored forms (dropped from the kernel).

The downstream lowers types, bodies and instances when it seals a boundary. Lowering then raising is idempotent on committed types and bodies, so the kernel needs no retention hook and no tokens.

### K6. The loader reports what it loaded (pending U8).

`book_load` (`1027–1103`) accepts an observer that receives, per file, the realpath, namespace, the exact text parsed and the file's event range, and a traversal mode that resolves imports without parsing bodies. Per U8(a), the downstream computes keys from these steps instead of re-parsing imports.

### K7. `main.ts`.

- **`cli_report` walks with a visited set.** Today's `term_refs` (`main.ts:545–557`) follows let payloads with no visited set; a chain of 24 typed lets costs ~70 s of CPU in the report alone. Reporting reads summaries where a caller provides them.
- **`--checkup` resumes from an immutable Base parent** only when a test's first import is `import Base`; otherwise it checks cold (U7). `book_seed` goes when `unsafe_seed` does.
- **A resume entry point** (`book_resume(parent, file)`) replaces `unsafe_seed` for the downstream, returning the child state, `n0` and the loader's observations; `unsafe_seed` is removed after the downstream migrates.
- **No process exit from library paths.** `book_read`'s `PROOF.bend` rule calls `cli_fail` (`597`, exit at `572`); it becomes a thrown error rendered identically by the CLI.

### In-repo exit gate

- Every public input's `--check-only` output is byte-identical to the pinned reference.
- All public tests pass the gate's lanes.
- The six `tests/snapshot/` fixtures pass.
- `bend.ts` ≤ 43,000 and `comp.ts` ≤ 65,000 tokens.
- A resumed check re-installs and re-checks zero prefix records (structural counter).
- Parent tables are unchanged after a child's check, fill, instantiation and compile.
- The 24-deep let chain reports in linear time.

## Downstream work: `bend-proof-of-compile`

Done in that repository under its own rule (all semantics in Bend; TypeScript as capability host). Two constraints come from the in-repo capability:

- **Parent tables must keep writable properties.** A child installs names by assignment, and JavaScript refuses an assignment that would shadow a non-writable property, or an accessor without a setter, on the prototype chain. Lazily decoding tables must therefore use data properties, or accessors whose setters define an own property on the receiver.
- **A resumption is cold-equivalent only if no child fill carrying `i` or `u` targets a parent's law** (U1). A child's declaration view of a parent law is the parent's own, without the leak cold parse-all gives it; so when the suffix fills a parent law with a foreign or `@unsafe` fill, the downstream resumes from an earlier root instead.

1. **Codec to U2** (`src/codec.ts`):
   - drop stored elaborations (F1);
   - per-definition records of raw type syntax, lowered bodies, ADT and constructor raw types, closed instance arguments, and summaries;
   - lazy decode per touched definition, through lazy table objects the kernel reads as plain properties;
   - canonical encoding with golden vectors.
2. **Resume through K2** instead of `cloneCheckedBook` (F2). Children are overlays over restored parents.
3. **Keys from the loader's observations** (K6, U8(a)): the Bend application folds the kernel's steps and the exact bytes parsed.
4. **U1's sealing rule**, computed in Bend from event metadata the capability reports: a boundary is sealed only if no law declared at or before it has a later fill carrying `i` or `u`.
5. **Compilation by re-elaboration.** Replay events in order; install unreachable definitions without checking; check `main`-reachable ones under the visibility of their events; then emit. At most a cold check of the reachable definitions.
6. **Reporting from summaries**, with flags read from the current view, since a child's foreign or `@unsafe` fill can make parent definitions rely on it.
7. **Trust per U5; GC** from Bend-emitted live-key manifests (the MVP's next step 3); dependency-before-root publication.
8. **Measure against the MVP's own benchmark (F4)** and Gate M's targets.

## Gate M

**Split by what load affects.** The host is shared, and another session's private-corpus checks keep the load average above 20 for hours. Counts, sizes, verdicts and in-process ratios run now. Absolute CPU and RSS and cross-run comparisons wait for a quiet host: a one-minute load average below 1.5 and no foreign CPU-heavy process, checked before and after. The timing half gates acceptance, not development.

**Load-insensitive results on the private workload (2026-09-23; ratios within one run):**

| Measure | Result | Verdict |
|---|---|---|
| M0 | Parse 0.44% of parse+check; prefix re-parse 0.37% of a full check; entry file 4.9% of check (33 of 1213 events); final module 0.05% | Entry-only incremental ≈ 5% of a full check |
| M1 | Raw types and lowered bodies: 11.5 MB (prototype JSON) for 1181 definitions plus 0.81 MB of source; no template instances; stored elaborations would be 892 MB | Pass |
| M3 | Touched prefix per file: median 3.0%, p90 8.4%, max 18% (entry: 186 of 1148; final module: 53 of 1135). Restoring the entry's touched set: ~92 ms in the prototype, 0.07% of a full check. Today's report touches 100% | Pass, pending the timing half |
| M4 | Summaries computed at commit: 0.62% of check | Pass |
| S | Summary references identical at commit and report time | Pass |
| U1 | 0 foreign or `@unsafe` fills; all 32 filled laws are Base's; declaration-only prototype output identical to the reference | U1 does not affect the private workload |
| M5 | Not run | Pending a quiet host |

**Public-corpus measurements (round 2):** re-parse restore of Base 28–32 ms per process against ~0.1 ms for its touched set; lowering elaborations 25–82% of check on Base/defs/generics/proofs; lowering types 4–13%, which U2's raw-syntax storage avoids; Map-based lookup +0–5% check CPU; SHA-256 1.5–1.9 GB/s.

**Criteria still to meet on a quiet host:** persistence overhead ≤ 10% of the full-check CPU per scenario; each incremental scenario below its full check; ≤ 3× RSS at every retained-prefix count; M5 spread reported, with CPU margins at least twice the spread. Sub-budgets are judged by instructions retired and operation counts, not five-run medians.

**Harness.** `~/Library/Caches/bend-snapshots/gate-m-163230d1/` holds:
- a pristine pinned copy with an anchored instrumentation patch (`patch.py`);
- the driver (`gm.ts`, run under `BUN_BE_BUN=1` with the reference binary as the Bun runtime);
- the U1 prototype;
- `run-gate-m-counts.sh` (load-insensitive) and `run-gate-m.sh` (quiet host).

## Slices

| Slice | Contents | Status |
|---|---|---|
| A | Reference, fixtures, Gate M load-insensitive half, decisions | Done except U3, U5, U8 and the timing half |
| B | In-repo K1–K4 and K7; `--checkup` fix; exit gate above | Done (uncommitted); K6 pending U8 |
| C | Downstream migration (items 1–7) in `bend-proof-of-compile`; retire `unsafe_seed` | After B; U8 for keys, U5 for trust |
| D | Acceptance: restart tests; driver lane within the 30 s gate cap; property tests; private acceptance on a quiet host; Lean laws per U3 | After C |

## Verification

| Requirement | Evidence |
|---|---|
| Immutable parents | Parent tables, records and stored bytes unchanged after a child's check, fill, instantiation, failure and compile; sibling children filling one law differently both match cold |
| Constant-size snapshots | O(1) overlay extension; bounded manifests; zero copies of old records |
| Incremental shared chunks | Only new definitions are encoded; source pages shared |
| Exact loading | Keys from the loader's own steps; namespaces, duplicates, cycles, order, spans, `n0` |
| Cold equivalence | Every public input's output byte-identical; fixtures pass all lanes; sealed boundaries respect U1's rule |
| Freshness | Edited file, retargeted symlink, `LAWS.bend` appearance and moved entry each select a shorter prefix |
| Authenticated restoration | Per U5 |
| Check-only | Zero emitter invocations when checking or sealing |
| Errors | No process exit from library paths; storage failures never reported as type errors |
| Memory and CPU | Gate M criteria on a quiet host |
| Source discipline | No private material tracked; caps held; one checker, one import parser (U8), one key function |

## Costs and non-goals

- **Compilation from a restored state re-elaborates** what `main` reaches: at most a cold check of those definitions. Check-only workloads never pay it.
- **A boundary whose prefix depends on a later fill's `i` or `u` is not sealed** (U1); the batch extends instead.
- **Kernel additions are paid for by compaction**, so each costs review of behavior-preserving rewrites.
- **Excluded:** stored elaborations, remote reads during restore, cross-version migration, path relocation, daemon-only reuse, per-function machine-code caching, language changes, hash proofs, private-proof vendoring.

## Appendix: first-order evaluator migration

Only if HOAS sharing proves unsound in a way K1–K3 cannot contain. It would replace `HBody`, `LetsOf` closures and function-valued `Env` entries (`bend.ts:274–306`) and the write-back cells, and it would migrate `comp.ts`'s closure applications (`712`, `1497–1498`, `2498`, `3094`, `3171`) and identity-keyed caches. It exceeds the token caps several times over.

## Execution record

- **Reference evidence.** An independent executable from `163230d1` (Bun 1.4.2) passed a complete private-workload `--check-only` run; evidence in `$HOME/Library/Caches/bend-snapshots/reference-163230d1.vGgyQZ/`.
- **Revisions.**
  - Rev 2: durable `LTerm`s plus Gate M.
  - Rev 3: three round-1 reviews.
  - Rev 4: five round-2 reviews.
  - **Rev 5 (2026-09-23):** records the user's decisions (U1 cold semantics, U2 types and bodies, U4 persistence downstream within the caps, U6/U7 adopted, downstream = `bend-proof-of-compile`); splits the work into the in-repo checker capability (K1–K7) and the downstream migration; adds findings F1–F4 about the downstream MVP and the open U8.
- **Slice B (in-repo, uncommitted).** Changes:
  - `bend.ts`: a fill copies the law's record (K1); `book_valid` resumes from `done` over the parent's tables and deletes its prefix re-install branches (K2); 42,979 → 42,956 tokens.
  - `main.ts`: `book_over` replaces `book_seed`'s whole-book copy; `book_flat` flattens a child before run, compile or report; `--checkup` seeds from Base only when `import Base` is a test's first import; `term_refs` keeps a visited set; the `PROOF.bend` rule throws instead of exiting, with identical CLI output; 7,295 → 7,636 tokens.
  - `comp.ts`: unchanged.

  Verification:
  - All 1,504 public inputs' `--check-only` output and all 1,433 `--checkup` sections are byte-identical to the pinned reference.
  - 1,121 Base-first tests checked as children of one Base parent with frozen records: zero parent writes, zero re-installed parent names, and the parent's tables unchanged.
  - For 635 of those children with a `main`, C and JS emitted from the flattened child equal the cold compile byte for byte.
  - Sibling children filling one open parent law as `Nat` and as `Bool` match the cold oracle (`7n`, `True{}`), and the parent's law stays open.
  - The 16-, 20- and 24-deep let chains report in 0.22–0.24 s of user CPU (the reference takes 5.48 s at depth 20).
  - No new type errors: HEAD and the working tree share the same two pre-existing ones (`bend.ts:2125`, `3828`).
  - An emulation of `gates/repo.ts` with the `ttok` tokenizer passes.
  - The cluster gates have not been run.
- **Commits (2026-09-23), branch `expose-book-state-api`:** `a583f801` (linear let-chain reporting and emission), `625b8460` (fixtures), `f0568d4f` (K1, K2, `book_over`, `book_flat`, `--checkup`), `15b83be6` (`PROOF.bend` throws), `2a73ce8b` (K6 observer), `8d230339` (a flat seed's constructors), `6e37fa9f` (`book_read` returns a seeded book flat), `80ffd6d1` (K3b), pushed to GitHub. `bend-proof-of-compile` branch `correct-incremental-compilation` (`49ce6de`, pushed) pins `bend-src` to `github:o1lo01ol1o/bend/expose-book-state-api` at `80ffd6d1` (its install check passes) and adds `SPEC-incremental-compilation.md`, which supersedes this plan's downstream section.
- **Upstream PR (2026-09-23):** bendlang/bend#1010, branch `resumable-checked-books`: the nine commits through `80ffd6d1` ported onto upstream `main` `6a77e124` (not `16379eb7`, the replay commit), verified there locally; fits upstream's caps (44,000 / 64,000 / 10,000).
- **Slice A.** Six public fixtures under `tests/snapshot/` (uncommitted) pass the check, interpretation, JS and C lanes locally (C with the system clang 15; the Homebrew clang 13 first on `PATH` is too old). Gate M's load-insensitive half ran on the private workload. No production compiler source has changed. `AGENTS.md` (uncommitted) authorizes kernel edits for this plan.
