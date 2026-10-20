# UFDA bibliography and first ten readings

BibTeX / Zotero: [core](bibliography-core.bib) (the first ten), [extra](bibliography-extra.bib) (more readings), [misc adjacent](bibliography-misc-adjacent.bib) (interesting adjacent stuff).

The intended use is to explain UFDA, not reconstruct an influence history. Downloads, abstract familiarity, and citation occurrence do not establish deep reading or adoption. Abstract interpretation is outside this reading set. Spoofax has one canonical citation and is explicitly familiar but unread.

## The first ten

1. **Voogd, Kløvstad, Johnsen et al. (2025). [Compositional Symbolic Execution Semantics](https://doi.org/10.1016/j.tcs.2025.115263).** Start with the central semantics reference: how symbolic paths compose. Read the semantic definitions and concrete correspondence.

2. **Henzinger, Majumdar, Raskin (2005). [A classification of symbolic transition systems](https://doi.org/10.1145/1042038.1042039).** Learn the STS vocabulary before interpreting AYXG’s representation. Focus on definitions; do not assume decidability results transfer.

3. **Lucanu, Rusu, Arusoaie (2017). [A Generic Framework for Symbolic Execution: A Coinductive Approach](https://doi.org/10.1016/j.jsc.2016.07.012).** Understand concrete/symbolic correspondence coinductively. This supplies the proof vocabulary for reading WRUH’s own theorem.

4. **Shoshitaishvili, Wang, Salls et al. (2016). [SOK: (State of) The Art of War: Offensive Techniques in Binary Analysis](https://doi.org/10.1109/SP.2016.17).** Locate angr in the binary-analysis pipeline. Read the symbolic-execution and architecture discussion, not the entire security survey.

5. **Yoshihiko Futamura (1999). [Partial Evaluation of Computation Process—An Approach to a Compiler-Compiler](https://doi.org/10.1023/A:1010095604496).** Read the first projection: specialize an interpreter with respect to a fixed program. The 1971 original is an alternative reading copy.

6. **Cerna, Kutsia (2023). [Anti-unification and Generalization: A Survey](https://doi.org/10.24963/ijcai.2023/736).** Read the survey’s core anti-unification/generalization account to understand IXYK’s reusable instruction schemas. This covers a current UFDA component rather than a new research direction.

7. **Heule, Schkufza, Sharma et al. (2016). [Stratified Synthesis: Automatically Learning the x86-64 Instruction Set](https://doi.org/10.1145/2908080.2908121).** Understand the counterexample-guided instruction-semantics comparison explicitly named for future repair.

8. **Craaijo, Verbeek, Ravindran (2024). [libLISA: Instruction Discovery and Analysis on x86-64](https://doi.org/10.1145/3689723).** Pair Strata with instruction discovery and hardware-based semantics. This explains the other explicitly named repair reference.

9. **Roșu, Șerbănută (2010). [An Overview of the K Semantic Framework](https://doi.org/10.1016/j.jlap.2010.03.012).** Understand the higher-level semantic specification target. K is a roadmap destination, not an existing generated output.

10. **Bettscheider, Zeller (2024). [Look Ma, No Input Samples! Mining Input Grammars from Code with Symbolic Parsing](https://doi.org/10.1145/3663529.3663790).** An actual inspiration for this work. Read for recovering structured input specifications from code through symbolic parsing.

## More Readings

### Symbolic execution and model correspondence

- [A formal foundation for symbolic evaluation with merging](https://doi.org/10.1145/3498709) — Direct comparison.

- [Correct and Complete Symbolic Execution for Free](https://doi.org/10.1007/978-3-031-76554-4_13) — Direct comparison.

- [Symbolic execution and program testing](https://doi.org/10.1145/360248.360252) — Present foundations.

- [Symbolic execution formally explained](https://doi.org/10.1007/s00165-020-00527-y) — Present foundations.

### Specification targets and logical bridges

- [Separation Logic: A Logic for Shared Mutable Data Structures](https://doi.org/10.1109/LICS.2002.1029817) — Reynolds (2002). Separation logic for reasoning about shared mutable data structures.

- [Specifying Systems: The TLA+ Language and Tools for Hardware and Software Engineers](https://lamport.org/tla/book.html) — Lamport (2002). The TLA+ specification language and tools.

- [A Compositional Natural Semantics and Hoare Logic for Low-Level Languages](https://doi.org/10.1016/j.tcs.2006.12.020) — Roadmap support.

- [Symbolic Execution of Constrained Horn Clauses](https://doi.org/10.48550/arXiv.2610.03345) — Roadmap support.

- [A Complete Formal Semantics of x86-64 User-Level Instruction Set Architecture](https://doi.org/10.1145/3314221.3314601) — Direct comparison.

- [Hoare-style logic for unstructured programs](https://doi.org/10.1016/j.jlamp.2025.101099) — Roadmap support.

- [The VMT-LIB Language and Tools](https://doi.org/10.48550/arXiv.2109.12821) — Roadmap support.

- [ISA Semantics for ARMv8-A, RISC-V, and CHERI-MIPS](https://doi.org/10.1145/3290384) — Direct comparison.

- [The Spoofax Language Workbench: Rules for Declarative Specification of Languages and IDEs](https://doi.org/10.1145/1869459.1869497) — Roadmap support. Familiar but unread.

- [Semantics Engineering with PLT Redex](https://mitpress.mit.edu/9780262062756/semantics-engineering-with-plt-redex/) — Roadmap support.

- [Matching Logic](https://doi.org/10.23638/lmcs-13(4:28)2017) — Roadmap support.

### Equivalence and observations

- [Symbolic bisimulations](https://doi.org/10.1016/0304-3975(94)00172-F) — Direct comparison.

- [The Linear Time – Branching Time Spectrum](https://doi.org/10.1007/BFb0039066) — Roadmap support.

- [The Linear Time – Branching Time Spectrum II: The Semantics of Sequential Systems with Silent Moves](https://doi.org/10.1007/3-540-57208-2_6) — Roadmap support.

- [Three Partition Refinement Algorithms](https://doi.org/10.1137/0216062) — Roadmap support.

- [Introduction to Bisimulation and Coinduction](https://doi.org/10.1017/CBO9780511777110) — Present foundations.

### Partial evaluation and interpreter projection

- [A Functional Correspondence between Evaluators and Abstract Machines](https://doi.org/10.1145/888251.888254) — Direct comparison.

- [Compiling symbolic execution with staging and algebraic effects](https://doi.org/10.1145/3428232) — Direct comparison.

- [Definitional interpreters for higher-order programming languages](https://doi.org/10.1145/800194.805852) — Present foundations.

- [Jones-optimal partial evaluation by specialization-safe normalization](https://doi.org/10.1145/3158102) — Direct comparison.

- [Partial Evaluation, Whole-Program Compilation](https://doi.org/10.1145/3729259) — Direct comparison.

- [Partial computation of programs](https://doi.org/10.1007/3-540-11980-9_13) — Direct comparison.

- [Partial evaluation and automatic program generation](https://studwww.itu.dk/people/sestoft/pebook/) — Present foundations.

- [Practical partial evaluation for high-performance dynamic language runtimes](https://doi.org/10.1145/3062341.3062381) — Direct comparison.

### Specification recovery and provenance

- [Proof-carrying parameters in certified symbolic execution](https://doi.org/10.1093/jigpal/jzad008) — Roadmap support.

- [Precise dynamic slicing algorithms](https://doi.org/10.1109/ICSE.2003.1201211) — Roadmap support.

- [The Debugging Book](https://www.debuggingbook.org/) — Roadmap support.

### Instruction repair and testing

- [A Methodology for Testing CPU Emulators](https://doi.org/10.1145/2522920.2522922) — Roadmap support.

- [Path-Exploration Lifting: Hi-Fi Tests for Lo-Fi Emulators](https://doi.org/10.1145/2150976.2151012) — Roadmap support.

- [Testing intermediate representations for binary analysis](https://doi.org/10.1109/ASE.2017.8115648) — Roadmap support.

### Binary extraction and fidelity

- [Accurate and Extensible Symbolic Execution of Binary Code based on Formal ISA Semantics](https://doi.org/10.23919/DATE64628.2025.10993257) — Direct comparison.

- [Bridging the Gap between Real-World and Formal Binary Lifting through Filtered-Simulation](https://doi.org/10.1145/3720524) — Direct comparison.

- [Extracting instruction semantics via symbolic execution of code generators](https://doi.org/10.1145/2950290.2950335) — Direct comparison.

### Instruction schema generalization

- [A Note on Inductive Generalization](https://homepages.inf.ed.ac.uk/gdp/publications/MI5_note_ind_gen.pdf) — Present foundations.

### Testing evidence

- [STADS: Software Testing as Species Discovery](https://doi.org/10.1145/3210309) — Roadmap support.

## Interesting adjacent stuff

- [Compositional Symbolic Execution for Correctness and Incorrectness Reasoning (Extended Version)](https://doi.org/10.4230/LIPIcs.ECOOP.2024.25). Separation-logic compositional execution is a plausible future bridge, but the concrete memory/specification interface to AYXG has not been established. Keep behind the two explicitly named Hoare papers.

- [Compositional Symbolic Execution for the Next 700 Memory Models](https://doi.org/10.1145/3763151). Memory-model-parametric symbolic execution may help compare semantic interfaces, but no specific UFDA dependency on this framework is established.

- Symbolic transition graph with assignment. Symbolic transition graphs with assignment sound structurally close, but the record lacks date, venue, and a resolvable link. Do not promote on title similarity alone.

- [Generating Inputs for Grammar Mining using Dynamic Symbolic Execution](https://doi.org/10.22152/programming-journal.org/2025/10/16). Input generation for grammar mining supports a possible application, rather than the current extraction/projection pipeline.

- [Inferring Attributed Grammars from Parser Implementations](https://doi.org/10.48550/arXiv.2507.13117). Attributed-grammar recovery could extend the thread's grammar direction, but the recursive-descent-parser setting is narrower than UFDA's generic model extraction.

- [Mining input grammars from dynamic control flow](https://doi.org/10.1145/3368089.3409679). Dynamic grammar mining is close to Look Ma, but would broaden a small comparison strand into a separate reading list. Retain only if grammar recovery becomes central to the description.

- [Towards Attribute Grammar Mining by Symbolic Execution](https://doi.org/10.1109/SANER53432.2022.00100). Attribute-grammar mining by symbolic execution is a plausible alternative in the same peripheral grammar strand; not a required foundation.

- [Sem86: A Full-System Emulator Without Hard-Coded Semantics](https://liblisa.nl/publications/sem86-qrs26/). Sem86 sounds close to instruction-model bootstrapping, but the stored record has no abstract and its precise reuse/validation relation needs a primary-source check before promotion.

- An Introduction to Separation Logic (Preliminary Draft). Separation logic is explicitly a roadmap target, but this undated preliminary-draft record is not yet an adequate canonical citation. Resolve the edition or substitute a verified foundational source.

- [Verification modulo theories](https://doi.org/10.1007/s10703-023-00434-x). The VMT survey includes abstraction-refinement algorithms beyond the requested export bridge. VMT-LIB is sufficient for the present reading set; this is not evidence that UFDA performs abstract interpretation.

- [babble: Learning Better Abstractions with E-Graphs and Anti-Unification](https://doi.org/10.1145/3571207). E-graph anti-unification is a possible implementation choice for specification generalization. No UFDA e-graph design justifies assigning this now.

- [egg: Fast and extensible equality saturation](https://doi.org/10.1145/3434304). Equality saturation is a possible simplification technique, not a named UFDA mechanism or necessary prerequisite for the current account.

- [Causal program dependence analysis](https://doi.org/10.1016/j.scico.2024.103208). Causal program dependence may help future slicing work, but correspondence between its dependence notion and the proposed LSP/native/Python slicing task remains unchecked.

- [Observation-based approximate dependency modeling and its use for program slicing](https://doi.org/10.1016/j.jss.2021.110988). Observation-based approximate dependence may help source localization; approximation and adequacy for the desired correspondence are unresolved.

- [Semi-automating small-scale source code reuse via structural correspondence](https://doi.org/10.1145/1453101.1453130). Structural correspondence for source reuse resembles version-to-version repair, but the specific transfer to model/proof reuse is not established.

- [A Two-Phase Infinite/Finite Low-Level Memory Model: Reconciling Integer–Pointer Casts, Finite Space, and undef at the LLVM IR Level of Abstraction](https://doi.org/10.1145/3674652). LLVM pointer and memory-model details would matter for an LLVM-specific bridge; the current roadmap does not select that bridge.

- [Branching Bisimulation Learning](https://doi.org/10.48550/arXiv.2504.12246). Computes an SMT-checked finite stutter-insensitive quotient of a supplied transition system. Potentially close to minimization, but bounded-branching, stuttering, and solver assumptions have not been matched to AYXG and its desired observations.

- [Symbolic Register Automata](https://doi.org/10.1007/978-3-030-25540-4_1). Defines symbolic register automata and algorithms for emptiness, inclusion, and equivalence. Compatibility of its register discipline and transition restrictions with AYXG has not been established; shared symbolic-state vocabulary alone is insufficient.

## Scope and source snapshot

The assessment follows [UFDA’s roadmap at acb7ce97f5cbda1dfb07ff335e47a0e86186ae79](https://github.com/heartpunk/ufda/blob/acb7ce97f5cbda1dfb07ff335e47a0e86186ae79/docs/roadmap.md), checked on 19 October 2026, and the [Bluesky thread](https://bsky.app/profile/heartpunk.com/post/3my5zgvy6mt2s). Current foundations and future directions are kept separate.

The anti-unification readings are grounded in the [IXYK instruction-schema and anti-unification components](https://github.com/heartpunk/ixyk/blob/b6779bb0ed4354c820fb831be1f4402170a0e5d1/README.md#L164-L170), at the revision pinned by UFDA, and other repos that will soon join ufda but need a lil more work first. Plotkin and the survey are [explicitly cited in IXYK](https://github.com/heartpunk/ixyk/blob/b6779bb0ed4354c820fb831be1f4402170a0e5d1/README.md#L219-L220).
