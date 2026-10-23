- shortcode glossary:
	- [ayxg](https://github.com/heartpunk/ayxg): symbolic transition system datatype and execution library in python and lean.
	- [wruh](https://github.com/heartpunk/wruh): extracts models of binaries into ayxg STSes.
	- [utem](https://github.com/heartpunk/utem): specializes fixed code or workload data through an ayxg model of an interpreter, compiler, vm, or kernel. a reference first futamura projector is implemented and proved correct in lean.
	- fyxo: an intended near term counterexample guided repair tool for ayxg STSes.
	- tmvm: a toy isa repo we (could in principle) use for some examples (private for now, will be public when it's needed; probs soon for a demo)
- overall, there's a few themes:
	- make it easier to prove anything for any system we can model
	- lift our specs off of dependence on compiled binaries
	- check and repair the specs efficiently wrt ground truth
	- systematize procedures for bootstrapping and prove correctness theorems about said bootstrap procedures wherever possible
		- an example
			- angr uses pyvex uses vex to do its symex. its vex is a fork of valgrinds that they mostly just directly lift and directly symbolically execute.
			- vex has dirty helpers which are lil non IRSB (most vex is just IRSBs; ir super blocks) helpers used for idk exactly what purpose in some spots. AES in particular is the one that showed up in an wruh/angr/cpython transitive dependency closure analysis of what mnemonics we could and couldn't support yet, which angr supported but we disabled for no great reason, etc.
			- angr can, in principle, be used by way of wruh to extract an STS model of that helper function
			- the STS can then be used as second backend, or translated by way of a gymrat (their lifter framework) integration so that angr can support those remaining gaps
			- similar techniques can work wrt emulators, decoders, etc. when relevant
			- the extracted model can also serve as a reference for a human or agent implementation that fits the upstream project's standards.
		- systematize this by making the existing collection scripts reproducible and using their results to propose issues for human or agent triage.[^collection]
- highest level goals, in rough order of priority tho this is very tentative, dk much what others will need or use of what i've built yet!
	- prove some useful security properties about some unix utils as compiled binaries in increasing complexity
		- don't attempt to lift the proofs to source yet
			- otoh, do wherever possible be as ready to support this as possible once the other prereqs are in place
		- do anchor them to functions
		- try to make repair easy wrt new versions, like, reuse any unchanged portions
		- had chroot -> sort -> sudo -> bash as some rough ideas but i do not claim they're the best ordering
	- self-model the transitive closure of wruh and prove end-to-end bisimilar extraction wrt the symex engine's emulation, by proving angr satisfies the [`SymexLaws`](https://github.com/heartpunk/wruh/blob/16d77877512d97fad0622a7a6ac401cf8b2dd538/Wruh/FreshExtraction.lean#L22-L31) used by utem's labeled extraction bridge.
		- extract the portion of cpython that angr depends on, project angr/wruh through that model, and prove that the resulting model of angr's implementation satisfies `SymexLaws`
			- requires a futamura projector[^futamura]. utem[^utem] now has a Lean-proved reference implementation, explained in [UTEM, a reference STS-to-STS 1st Futamura projector](roadmap/utem.md). i've done an initial correspondence skim; deeper review, concrete examples, documentation cleanup, and deciding the next steps toward CPython remain.[^utem-proof]
			- also requires source correspondence through extraction and projection. wruh already records binary instruction provenance, and utem retains original edges. TODO connect this to the relevant python source locations and preserve that correspondence through the pipeline.[^provenance]
			- rough plan:
				- trace a wruh extraction at native and python levels
				- get list of python modules/files used as well as any native deps
				- enumerate opcodes from `.pyc` files corresponding to previously identified `.py` files
				- extract cpython functions implementing those opcode handlers and the transitive dependency set within binary (cross binary maybe useful later depends on the purpose but we need a scope so we'll start single binary)
				- futamura project angr and wruh python code through the cpython sts getting an sts for wruh and angr's python code; source indexing gives us a semantics relative to this cpython binary *but also tied to the python source level*
				- use the angr/wruh sts and python source correspondence to prove `SymexLaws` satisfaction
	- pick cpython or any other interpreter and futamura project code through it to get proofs for python/js/ruby/whatevs
	- for compilers, ensure minimally viable integration and or integrability by end users at minimum (decide the bar as part of issue) between debug symbols and our models so it's possible to just do wruh extraction post binary and map that back to source at the function level for rn
		- a futamura projector would allow for arbitrary expression level stuff and is probably not strictly necessary; you can always do a wruh extraction post compilation! and unless the extracted slice of the compiler is adequately focused it is unlikely to provide substantial advantage unavailable by the theory encoded in LSPs
			- it's not sufficient for expression level alone tho, probs need to localize and backward slice and compose some bits of the compiler. possible but a whole thing.
			- operating over languages' LSPs, like, modeling them instead of just compilers, could be a better integration point. a good LSP already encodes a lot of the theory of how to use the language tooling efficiently and interactively to get types and other developer-facing information.
				- model the LSP implementation and backward-slice the computations producing selected responses, across libraries or binaries where needed. then lift those computations into our integration, reusing the LSP's existing interface to the compiler/interpreter instead of figuring out how to drive it ourselves.
				- that could actually be a path for a meta-lsp. our LSP could model and extend other LSPs with info about the wruh model, and, where we've done the integration w/that specific LSP, perhaps even map WRUH level inferred contracts up into language specific types and predicates. most of the data required for this is in our models, but there's substantial new research to do to implement it. or at least a good review of the current literature!
	- differential fuzzing should probs pop outta wruh but be tightly integrated w/it and ayxg. angr's models aren't perfect wrt every piece of hardware, and some users need fidelity to particular silicon and have compute to spend establishing it.
		- investigate Strata/libLISA-style counterexample-guided repair, starting from the semantic models our existing decoder/lifter-to-model pipeline gives us. the intended saving is reusing that structure rather than constructing starting semantic templates from scratch.
		- for x86, XED/ENC2 is a candidate for generating parameterized instruction instances to lift through PyVEX and compare against native execution. that would let us reuse existing encoding machinery too.
		- this is a capability we could prioritize when someone needs it.
		  
	- the repair stuff is its own thing too, probs also another repo
	- generating higher level specs like k framework or tla+ specs and/or just generating partial ones as ASTs w/typed holes or even a hypergraph encoding the constraints and presenting it to the user/agent as an action space
- further down the road:
	- use some theorems re compatibility as bisimulation modulo a quotient and show that if we can show compatibility wrt a number of emulators then wrt that core feature set we can say we're Correct Enough™ in that sense[^compat]
	- evidence management layer for fuzzing; maybe should go sooner, but it isn't particularly useful in an ongoing way until the following point, so... like, for counterexample based semantics repair we can just record the single counterexample. you only need a richer framework imo when you need to do the probability of being wrong calcs
	- theorems about how probable semantic gaps remain modulo a certain set of assumptions i think p reasonable:
		- no malicious backdoors (they may exist, but we don't hunt them)
		- nondeterminism is either a sidechannel we don't model (for now; those are just outta scope for now) or intended and of three sorts
			- timers (monotonic increase across samples)
			- (P)RNGs
			- interleaving order of concurrent executions
		- stable semantics

- open transfers (got an archived pr for this ready for review on truenas)
- docker image (got a pr for this that is overdone and messy but an adequate basis for something clean enough)
- remove hard bazel dependency for at least end users; maybe leave it for wruh/ayxg devs
- python/lean packages
- readme updates w/like a rough outline of the most important directories/declarations maybe
- TODO after release, reflect the component-specific roadmap material and companion docs in the relevant repos (e.g. the UTEM walkthrough in UTEM), with links both ways so the context is findable from either place.
- an issue for each of the thingers in the two tables below
- self hosting for primitive ops, tl;dr: some generic symbolic transition systems encoding all of ints, floats, bitvecs, and bools. also needs to be capable of doing strings and arbitrary datatypes
- review the existing Lean migration: [ayxg PR #1](https://github.com/heartpunk/ayxg/pull/1) removes the deprecated wrapper and preserves transition labels; [wruh PR #2](https://github.com/heartpunk/wruh/pull/2), branch `bisim-flake-alignment`, ports extraction and its bisimulation proof to that interface.[^migration]
- ayxg lean to python roundtripping property tests tied to the behavioral correspondence tests
- vex driven (so long as angr dependent) coverage suite; for all ops vex can decode, make a static covering suite of binaries that exhibit all behavior vex supports. if ever there's a gap, the test fails and we add a new binary or update an existing one to cover it.
	- not hypothesis driven and dynamic bcz executing truly randomly generated assembly just requires more security thinking than i wanna do rn. but if we had integration w/e.g. dhyve (deterministic fork of bhyve, a deterministic hypervisor in the vein of what antithesis software does), then we could do it fully random.
- bisimulation minimization to erase host level details from specs; paired w/self hosting for primitive ops this gives us a nanopass that gets us closer to k framework style specs being generatable fairly mechanically
- bridges to other formalisms
	- [vmt-lib](https://vmt-lib.fbk.eu/home)
	- hoare logics oriented toward low level code [Saabas and Uustalu (2007)](https://doi.org/10.1016/j.tcs.2006.12.020); [Lundberg et al. (2026)](https://doi.org/10.1016/j.jlamp.2025.101099)[^hoare]
	- separation logic
	- matching logic
	- constrained horn clauses
- ayxg visualizer
	-  there's prior art in [mxoq on main](https://github.com/heartpunk/mxoq/blob/05e5273f90136de354d8dffe6491c66fa178dcb8/imark.html#L3980-L4027)[^mxoq]. it's not ideal but it does give *an* example of what it could look like.
- TODO document the requirement that the STS represents the complete modeled execution semantics, including control flow, with the separate control parameter set to `Unit` (the pending Lean stepping/extraction PRs already use `Unit`; the general AYXG type still permits other control types)
- there is (was? i don't think i fixed it...) a weird lil gotcha where traps are considered metadata not part of canonical state. easy to repair. just need to pull more into the state. the proof stands regardless, its just implicitly wrt a smaller relation in a way that will break application unless the trap and abort style outcomes are piped thru e2e

two tables of major remaining blockers from a completed extraction attempt on libpython3.12.so.1.0[^counts]

that attempt produced extracted models for 22,741 of 28,078 candidate function entry addresses, with 5,337 recorded failures. each category below counts the first observed failure for a function; fixing it may expose another failure in that same function.

| Remaining major mechanism                              | Failures |
| ------------------------------------------------------ | -------- |
| Noncanonical function-owner identifiers                | 2,736    |
| Overlapping static blocks                              | 1,170    |
| Call fallthrough crossing the declared function extent | 1,000    |

| Tail                                                                                        | Failures |
| ------------------------------------------------------------------------------------------- | -------- |
| SMT export sort/width errors                                                                | 255      |
| Unsupported Z3 operators                                                                    | 113      |
| VEX decode gaps                                                                             | 38       |
| Unsupported CCall helpers                                                                   | 10       |
| [Unsupported Dirty helpers](https://chatgpt.com/share/6ad17e38-1674-83e8-88b1-cb2b7f2ee752) | 8        |
| Unsupported jump kinds                                                                      | 3        |
| Symbol-extent problems                                                                      | 2        |
| Miscellaneous symbolic-expression issues                                                    | 2        |

[^utem]: [UTEM STS-to-STS projector sketch](roadmap/utem.md)
[^collection]: [Collection scripts for WRUH extraction](roadmap/collection-scripts.md)
[^compat]: [Compatibility relations across semantic stages](roadmap/compatibility.md)
[^hoare]: [Hoare logics for low-level code](roadmap/hoare-logics.md)
[^mxoq]: [MXOQ source-index prior art](roadmap/mxoq-source-index.md)
[^counts]: [CPython extraction attempt counts](roadmap/cpython-extraction-counts.md)
[^futamura]: Futamura (1971), *Partial Evaluation of Computation Process—An Approach to a Compiler-Compiler* ([English full text](https://fi.ftmr.info/PE-Museum/PE-Original-English1971.pdf)); revised 1999 reprint ([DOI](https://doi.org/10.1023/A:1010095604496), [author full text](https://fi.ftmr.info/PE-Museum/PE-Revised1999.pdf)).
[^migration]: AYXG [`SymbolicStep.lean`, lines 11–39](https://github.com/heartpunk/ayxg/blob/5106df06d92620da810c325b8779ce97a14f7f0e/Ayxg/LTS/QfAbv/SymbolicStep.lean#L11-L39); WRUH [`FreshExtraction.lean`, lines 12–39](https://github.com/heartpunk/wruh/blob/16d77877512d97fad0622a7a6ac401cf8b2dd538/Wruh/FreshExtraction.lean#L12-L39). Links are pinned to the reviewed revisions.
[^provenance]: WRUH [`artifact.py`, `Occurrence`, lines 491–514](https://github.com/heartpunk/wruh/blob/7b2f2fc7d456d2dc633ccfab085cc66159859ce9/extractor/artifact.py#L491-L514); UTEM [`Reference/Graph.lean`, `CompiledEdge`, lines 7–29](https://github.com/heartpunk/utem/blob/88efa92e1fe4c0553f8eba43dec198b19ebdeb31/Reference/Graph.lean#L7-L29). Links are pinned to the reviewed revisions.
[^utem-proof]: UTEM [`Reference/Projector.lean`, `project_correct`, lines 78–109](https://github.com/heartpunk/utem/blob/88efa92e1fe4c0553f8eba43dec198b19ebdeb31/Reference/Projector.lean#L78-L109), at the revision explained in the companion.
