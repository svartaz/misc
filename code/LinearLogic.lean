/- 
  coppy-pasted from https://github.com/leanprover-community/mathlib/blob/master/src/data/list/perm.lean 
-/
inductive List.perm {α : Type} : List α → List α → Prop
| nil   : perm [] []
| cons  : ∀ (x : α) {l₁ l₂ : List α}, perm l₁ l₂ → perm (x::l₁) (x::l₂)
| swap  : ∀ (x y : α) (l : List α), perm (y::x::l) (x::y::l)
| trans : ∀ {l₁ l₂ l₃ : List α}, perm l₁ l₂ → perm l₂ l₃ → perm l₁ l₃

@[reducible] def append : List α → List α → List α := List.append

inductive form : Type :=
| atom : Nat → form
| mTru : form
| mCon : form → form → form
| mImp : form → form → form
open form

notation "𝟙" => mTru
infix:50 "⊗" => mCon
infix:40 "⊸" => mImp

inductive deduce : List form → form → Prop :=
| atomI                    {A     : form} : deduce [A] A
| mTruI                                  : deduce nil 𝟙
| mTruE {Γ Δ : List form} {A     : form} : deduce Γ mTru → deduce Δ A → deduce (Δ ++ Γ) A
| mConI {Γ Δ : List form} {A B   : form} : deduce Γ A → deduce Δ Β → deduce (Δ ++ Γ) (A ⊗ B)
| mConE {Γ Δ : List form} {A B C : form} : deduce Γ (A ⊗ B) → deduce (B :: A :: Δ) C → deduce (Δ ++ Γ) C
| mImpI {Γ   : List form} {A B   : form} : deduce (A :: Γ) B → deduce Γ (A ⊸ B)
| mImpE {Γ Δ : List form} {A B   : form} : deduce Γ (A ⊸ B) → deduce Δ A → deduce (Δ ++ Γ) B
| perm  {Γ Δ : List form} {A     : form} : deduce Γ A → List.perm Γ Δ → deduce Δ A

infix:30 "⊢" => deduce

open deduce

def atomI0 := atomI (A := atom 0)
example : atomI0 = mImpE (mImpI atomI0) atomI0 := by
  simp

variable {A B C : form}

example : [B, A] ⊢ A ⊗ B := by
  apply mConI (Γ := [A]) (Δ := [B])
  apply atomI
  apply atomI

example : [B, A] ⊢ C → [A, B] ⊢ C := by
  intro
  apply perm
  assumption
  apply List.perm.swap
