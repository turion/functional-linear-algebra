{-# OPTIONS --without-K --safe #-}

open import Level using (Level)

open import Relation.Binary.PropositionalEquality hiding (∀-extensionality)
open ≡-Reasoning

open import Data.Nat using (ℕ; suc; zero)
open import Data.Vec using (Vec; foldr; zipWith; map)
                     renaming ([] to []ⱽ; _∷_ to _∷ⱽ_)

open import FLA.Algebra.Structures
open import FLA.Algebra.Properties.Field

module FLA.Algebra.LinearAlgebra where

private
  variable
    ℓ : Level
    A : Set ℓ
    m n p q : ℕ


_+ⱽ_ : ⦃ F : Field A ⦄ → Vec A n → Vec A n → Vec A n
_+ⱽ_ []ⱽ []ⱽ = []ⱽ
_+ⱽ_ (x₁ ∷ⱽ xs₁) (x₂ ∷ⱽ xs₂) = x₁ + x₂ ∷ⱽ (xs₁ +ⱽ xs₂)
  where open Field {{...}}

-- Vector Hadamard product
_∘ⱽ_ : ⦃ F : Field A ⦄ → Vec A n → Vec A n → Vec A n
_∘ⱽ_ = zipWith _*_
  where open Field {{...}}

-- Multiply vector by a constant
_*ᶜ_ : ⦃ F : Field A ⦄ → A → Vec A n → Vec A n
c *ᶜ v = map (c *_) v
  where open Field {{...}}

-- Match the fixity of Haskell
infixl  6 _+ⱽ_
infixl  7 _∘ⱽ_
infixl 10 _*ᶜ_

sum : ⦃ F : Field A ⦄ → Vec A n → A
sum = foldr _ _+_ 0ᶠ
  where open Field {{...}}

module sumProperties ⦃ F : Field A ⦄ where
  open Field F

  sum-distr-+ⱽ : (v₁ v₂ : Vec A n) → sum (v₁ +ⱽ v₂) ≡ sum v₁ + sum v₂
  sum-distr-+ⱽ []ⱽ []ⱽ = sym (0ᶠ+0ᶠ≡0ᶠ)
  sum-distr-+ⱽ (v₁ ∷ⱽ vs₁) (v₂ ∷ⱽ vs₂) rewrite
      sum-distr-+ⱽ vs₁ vs₂
    | +-assoc (v₁ + v₂) (foldr (λ v → A) _+_ 0ᶠ vs₁) (foldr (λ v → A) _+_ 0ᶠ vs₂)
    | sym (+-assoc v₁ v₂ (foldr (λ v → A) _+_ 0ᶠ vs₁))
    | +-comm v₂ (foldr (λ v → A) _+_ 0ᶠ vs₁)
    | +-assoc v₁ (foldr (λ v → A) _+_ 0ᶠ vs₁) v₂
    | sym (+-assoc (v₁ + (foldr (λ v → A) _+_ 0ᶠ vs₁)) v₂ (foldr (λ v → A) _+_ 0ᶠ vs₂))
    = refl

open sumProperties

-- Inner product
⟨_,_⟩ : ⦃ F : Field A ⦄ → Vec A n → Vec A n → A
⟨ v₁ , v₂ ⟩ =  sum (v₁ ∘ⱽ v₂)