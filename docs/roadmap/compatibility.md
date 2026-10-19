# Compatibility relations across semantic stages

Source: the self-contained Lean listing supplied with this roadmap discussion. The listing below adds one opening `namespace Compatibility` line to match the supplied `end Compatibility`; no other Lean text was changed. The resulting standalone file typechecked with `lean` locally on 2026-10-16.

This is the recovered prior code, with one level of module nesting elided. The intended instantiations compare AYXG models of the same ISA behavior from different emulators—for example, RISC-V addition—under a chosen abstraction or observation view.

The aim is to characterize a common supported behavior floor, make the boundaries of that support explicit, and help target native differential testing toward compatibility gaps and undefined behavior. This connects the compatibility machinery to both emulator-backed modeling and the separate work on fidelity to particular silicon.

`RelLe` and `RelEquiv` compare behavior relations by inclusion in one or both directions. A `StageView` holds a behavior relation and a `RelGalois` abstraction into an observation domain. `Compatible` compares observed relations; `CompatibleVia` first maps differing observation domains into a common one.

`StageArrow` records both a producer of the next-stage relation and the preservation obligation on observations. `StageArrow.comp` composes those witnesses. `compatibleVia_forward` and `compatible_forward` transfer compatibility forward. The converse theorem requires `ReflectsRelEquiv` because a lossy observation map can discard distinctions. This generic module contains no concrete emulator, binary, AYXG, K, or TLA+ instantiation.

## Complete Lean listing

````lean
namespace Compatibility

universe u v w x y z o

/-- A binary behavior relation over a carrier/state type.  A relation may be a
single-step transition relation, a path-summary relation, a concrete semantics
relation, or a spec-facing behavior relation, depending on the stage. -/
def Rel (S : Type u) : Type u := S → S → Prop

/-- Relation inclusion.  Read `RelLe R Q` as "every behavior allowed by `R` is
also allowed by `Q`". -/
def RelLe {S : Type u} (R Q : Rel S) : Prop :=
  ∀ s s', R s s' → Q s s'

/-- Logical equivalence of behavior relations, avoiding any dependence on
function extensionality/propositional extensionality in downstream statements. -/
def RelEquiv {S : Type u} (R Q : Rel S) : Prop :=
  RelLe R Q ∧ RelLe Q R

namespace RelEquiv

/-- Relation equivalence is reflexive. -/
theorem refl {S : Type u} (R : Rel S) : RelEquiv R R :=
  ⟨fun _ _ h => h, fun _ _ h => h⟩

/-- Relation equivalence is symmetric. -/
theorem symm {S : Type u} {R Q : Rel S} (h : RelEquiv R Q) : RelEquiv Q R :=
  ⟨h.2, h.1⟩

/-- Relation equivalence is transitive. -/
theorem trans {S : Type u} {R Q T : Rel S}
    (h₁ : RelEquiv R Q) (h₂ : RelEquiv Q T) : RelEquiv R T :=
  ⟨fun s s' h => h₂.1 s s' (h₁.1 s s' h),
   fun s s' h => h₁.2 s s' (h₂.2 s s' h)⟩

end RelEquiv

/-- A relation transformer between behavior domains.  The `respects` field says
that the transformer is well-defined on behavior equivalence classes: equivalent
input relations are sent to equivalent output relations.

Examples:
* identity, for fidelity-preserving stage arrows;
* a forgetful abstraction from full behavior to a coarser TLA+/API/property
  observation domain;
* a quotient induced by a language/spec observation boundary. -/
structure RelMap (A : Type u) (B : Type v) where
  map : Rel A → Rel B
  respects : ∀ {R Q : Rel A}, RelEquiv R Q → RelEquiv (map R) (map Q)

namespace RelMap

/-- Identity relation transformer. -/
def id (A : Type u) : RelMap A A where
  map := fun R => R
  respects := fun h => h

/-- Composition of relation transformers. -/
def comp {A : Type u} {B : Type v} {C : Type w}
    (g : RelMap B C) (f : RelMap A B) : RelMap A C where
  map := fun R => g.map (f.map R)
  respects := fun h => g.respects (f.respects h)

end RelMap

/-- A Galois-connection-like abstraction boundary between concrete behavior
relations over `C` and abstract/observed behavior relations over `A`.

The law

  `α R ≤ Q ↔ R ≤ γ Q`

says that checking whether the abstraction of concrete behavior `R` is contained
in abstract behavior `Q` is equivalent to checking whether `R` is contained in
the concretization of `Q`.

For now both orders are relation inclusion.  If a later abstract domain needs a
non-subset order, this structure can be generalized then. -/
structure RelGalois (C : Type u) (A : Type v) where
  α : Rel C → Rel A
  γ : Rel A → Rel C
  gc : ∀ (R : Rel C) (Q : Rel A), RelLe (α R) Q ↔ RelLe R (γ Q)

/-- A semantic view/stage in the pipeline.

`S` is the carrier for this representation.  `rel` is the behavior relation at
this stage.  `abs` gives the lawful abstraction boundary into the observation
domain `A`.  A binary, raw LTS, composed path model, CHC model, K spec, or TLA+
model can all be a `StageView` once its behavior relation has been supplied
(proved or trusted). -/
structure StageView (S : Type u) (A : Type v) where
  rel : Rel S
  abs : RelGalois S A

namespace StageView

/-- The observed behavior represented by a stage. -/
def observed {S : Type u} {A : Type v} (V : StageView S A) : Rel A :=
  V.abs.α V.rel

end StageView

/-- Compatibility of two views with the same observation domain: their observed
relations are logically equivalent. -/
def Compatible {S₁ : Type u} {S₂ : Type v} {A : Type w}
    (V₁ : StageView S₁ A) (V₂ : StageView S₂ A) : Prop :=
  RelEquiv V₁.observed V₂.observed

/-- Compatibility after first mapping each observed relation into a shared
comparison domain.  This is useful when two pipelines expose different
intermediate observation domains but both can be compared after a common
coarsening/profile. -/
def CompatibleVia {S₁ : Type u} {S₂ : Type v} {A₁ : Type w} {A₂ : Type x}
    {O : Type y}
    (β₁ : RelMap A₁ O) (β₂ : RelMap A₂ O)
    (V₁ : StageView S₁ A₁) (V₂ : StageView S₂ A₂) : Prop :=
  RelEquiv (β₁.map V₁.observed) (β₂.map V₂.observed)

/-- A witnessed transformation between two semantic views.

`F` is the actual producer of the next semantic object: path composition, loop
summarization, state quotienting, translation to CHC/K/TLA+, re-extraction, or
any other transformation once represented as a function on behavior relations.

`β` is the relation-level map between observation domains.  For full-fidelity
arrows, use `RelMap.id _`.  For intentionally lossy/coarser arrows, `β`
records exactly what information is forgotten.

The two fields correspond to the two rows of the diagram:

```text
V₁.rel ─────────────F────────────▶ V₂.rel
  │                                  │
  α₁                                 α₂
  ▼                                  ▼
observed(V₁) ───────β────────────▶ observed(V₂)
```

`produced_by` pins the top arrow; `preserves` pins the lower semantic
obligation, up to logical equivalence. -/
structure StageArrow {S₁ : Type u} {S₂ : Type v} {A₁ : Type w} {A₂ : Type x}
    (F : Rel S₁ → Rel S₂) (β : RelMap A₁ A₂)
    (V₁ : StageView S₁ A₁) (V₂ : StageView S₂ A₂) where
  produced_by : V₂.rel = F V₁.rel
  preserves : RelEquiv V₂.observed (β.map V₁.observed)

namespace StageArrow

/-- A stage arrow can always be read as preserving compatibility via the chosen
observation-domain transformer. -/
theorem observed_equiv {S₁ : Type u} {S₂ : Type v} {A₁ : Type w} {A₂ : Type x}
    {F : Rel S₁ → Rel S₂} {β : RelMap A₁ A₂}
    {V₁ : StageView S₁ A₁} {V₂ : StageView S₂ A₂}
    (arrow : StageArrow F β V₁ V₂) :
    RelEquiv V₂.observed (β.map V₁.observed) :=
  arrow.preserves

/-- Compose two stage arrows.  The resulting producer is ordinary function
composition on semantic relations; the resulting observation map is ordinary
composition of relation transformers. -/
def comp {S₁ : Type u} {S₂ : Type v} {S₃ : Type w}
    {A₁ : Type x} {A₂ : Type y} {A₃ : Type z}
    {F₁₂ : Rel S₁ → Rel S₂} {F₂₃ : Rel S₂ → Rel S₃}
    {β₁₂ : RelMap A₁ A₂} {β₂₃ : RelMap A₂ A₃}
    {V₁ : StageView S₁ A₁} {V₂ : StageView S₂ A₂} {V₃ : StageView S₃ A₃}
    (a₁₂ : StageArrow F₁₂ β₁₂ V₁ V₂)
    (a₂₃ : StageArrow F₂₃ β₂₃ V₂ V₃) :
    StageArrow
      (fun R => F₂₃ (F₁₂ R))
      (RelMap.comp β₂₃ β₁₂)
      V₁ V₃ where
  produced_by := by
    rw [a₂₃.produced_by, a₁₂.produced_by]
  preserves :=
    RelEquiv.trans a₂₃.preserves (β₂₃.respects a₁₂.preserves)

end StageArrow

/-- Forward compatibility transfer through possibly different observation-domain
maps.  If the source views are already compatible *via* the lower-row maps used
by their respective stage arrows, then the target views are compatible.

This is the two-implementation/pipeline version of the square: each side may
have its own induced quotient map, as long as those maps land in the same target
observation domain. -/
theorem compatibleVia_forward {S₁ : Type u} {S₂ : Type v}
    {T₁ : Type w} {T₂ : Type x}
    {A₁ : Type y} {A₂ : Type z} {B : Type o}
    {F₁ : Rel S₁ → Rel T₁} {F₂ : Rel S₂ → Rel T₂}
    {β₁ : RelMap A₁ B} {β₂ : RelMap A₂ B}
    {V₁ : StageView S₁ A₁} {V₂ : StageView S₂ A₂}
    {W₁ : StageView T₁ B} {W₂ : StageView T₂ B}
    (a₁ : StageArrow F₁ β₁ V₁ W₁)
    (a₂ : StageArrow F₂ β₂ V₂ W₂)
    (h : CompatibleVia β₁ β₂ V₁ V₂) : Compatible W₁ W₂ :=
  RelEquiv.trans a₁.preserves
    (RelEquiv.trans h (RelEquiv.symm a₂.preserves))

/-- Forward compatibility transfer through matching observation-domain
coarsening.  If two source views are compatible, and each is transformed by a
stage arrow whose lower-row map is the same `β`, then the target views are
compatible.

This is the safe direction for lossy abstractions such as a TLA+ model of a
subset/property: compatibility at higher fidelity implies compatibility after
forgetting detail. -/
theorem compatible_forward {S₁ : Type u} {S₂ : Type v}
    {T₁ : Type w} {T₂ : Type x} {A : Type y} {B : Type z}
    {F₁ : Rel S₁ → Rel T₁} {F₂ : Rel S₂ → Rel T₂}
    {β : RelMap A B}
    {V₁ : StageView S₁ A} {V₂ : StageView S₂ A}
    {W₁ : StageView T₁ B} {W₂ : StageView T₂ B}
    (a₁ : StageArrow F₁ β V₁ W₁)
    (a₂ : StageArrow F₂ β V₂ W₂)
    (h : Compatible V₁ V₂) : Compatible W₁ W₂ :=
  RelEquiv.trans a₁.preserves
    (RelEquiv.trans (β.respects h) (RelEquiv.symm a₂.preserves))

/-- A relation transformer reflects equivalence when equivalence after applying
it implies equivalence before applying it.  This is the extra hypothesis needed
for converses through a stage that might otherwise lose information. -/
def ReflectsRelEquiv {A : Type u} {B : Type v} (β : RelMap A B) : Prop :=
  ∀ {R Q : Rel A}, RelEquiv (β.map R) (β.map Q) → RelEquiv R Q

/-- Backward compatibility transfer through a faithful observation-domain map.
If `β` reflects equivalence, then compatibility after the stage implies
compatibility before the stage.  Without this hypothesis, lossy abstractions
only support the forward theorem above. -/
theorem compatible_backward_of_reflects {S₁ : Type u} {S₂ : Type v}
    {T₁ : Type w} {T₂ : Type x} {A : Type y} {B : Type z}
    {F₁ : Rel S₁ → Rel T₁} {F₂ : Rel S₂ → Rel T₂}
    {β : RelMap A B}
    {V₁ : StageView S₁ A} {V₂ : StageView S₂ A}
    {W₁ : StageView T₁ B} {W₂ : StageView T₂ B}
    (a₁ : StageArrow F₁ β V₁ W₁)
    (a₂ : StageArrow F₂ β V₂ W₂)
    (hReflects : ReflectsRelEquiv β)
    (h : Compatible W₁ W₂) : Compatible V₁ V₂ :=
  hReflects
    (RelEquiv.trans (RelEquiv.symm a₁.preserves)
      (RelEquiv.trans h a₂.preserves))

end Compatibility
````
