import Mathlib.Data.List.Perm
import Mathlib.Data.Multiset.Basic
import «Split»
import «Form»

def hello := "world"

-- https://github.com/leanprover-community/mathlib/blob/14e84382905302e3091536c4dcabb5bb09d63d21/src/data/list/perm.lean#L107
theorem perm_append_comm : ∀ {l₁ l₂ : List α}, (l₁++l₂) ~ (l₂++l₁)
| []   => by simp; apply List.Perm.refl
| a::t => (perm_append_comm.cons _).trans List.perm_middle.symm

inductive term: Type 
| fvar: String → term
| bvar: Nat → term
| abs : form → term → term
| app : term → term → term
open term

instance: Coe String term := ⟨fvar⟩
instance: Coe Nat term := ⟨bvar⟩

def fvars: term → List String
| fvar x    => [x]
| bvar _    => []
| abs _ t   => fvars t
| app t0 t1 => fvars t1 ++ fvars t0

def subst (t: term) (x: String) (u: term) :=
  match t with
  | bvar _    => t
  | fvar y    => if x = y then u else t
  | abs A t'  => abs A (subst t' x u)
  | app t0 t1 => app (subst t0 x u) (subst t1 x u)

def name (t: term) (n: Nat) (u: term) :=
  match t with
  | bvar n'   => if n = n' then u else t
  | fvar _    => t
  | abs A t'  => abs A (name t' (n + 1) u)
  | app t0 t1 => app (name t0 n u) (name t1 n u)

@[reducible] def env := List (String × form)

instance: Membership String env :=
  ⟨λ x Γ => x ∈ Γ.map Prod.fst⟩

inductive judge: env → term → form → Prop
| fvar {x: String} {A  : form}                    : judge [(x, A)] x A
| abs  {x: String} {A B: form} {Γ  : env} {h: x∉Γ}: judge ((x, A)::Γ) t B → judge Γ (abs A t) (A⊸B)
| app              {A B: form} {Γ Δ: env}         : judge Γ t (A⊸B) → judge Δ u B → judge (Δ++Γ) (app t u) B
| perm                         {Γ Δ: env}         : judge Γ t A → Γ ~ Δ → judge Δ t A

example: judge [(y, B), (x, A)] t C → judge [(x, A), (y, B)] t C := by
  intro h
  apply judge.perm
  assumption
  apply List.Perm.swap

inductive eval: 