import data.rat.basic
import data.real.basic
import data.finsupp algebra.big_operators
import algebra.ring
import ring_theory.algebraic
import field_theory.minimal_polynomial
import tactic.linarith
import tactic
import topology.metric_space.basic
import topology.basic
import topology.algebra.polynomial
import analysis.normed_space.basic analysis.specific_limits analysis.calculus.mean_value
import small_things

noncomputable theory
local attribute [instance] classical.prop_decidable

open small_things

def transcendental (x : real) := ¬(is_algebraic ℤ x)

def liouville_number (x : real) := ∀ n : nat, ∃ a b : int, b > 1 ∧ 0 < abs(x - a / b) ∧ abs(x - a / b) < 1/b^n


def irrational (x : real) := ∀ a b : int, b > 0 -> x - a / b ≠ 0

-- [a-1, a+1] is compact, hence a continuous function attains a maximum and a minimum.
lemma closed_interval_compact (a : real) : compact $ set.Icc (a-1) (a+1) :=
begin
  rw metric.compact_iff_closed_bounded, split,
  {
    -- closed
    exact is_closed_Icc,
  },
  {
    unfold metric.bounded,
    use 2, intros x₁ x₂ h1 h2, simp at h1 h2, unfold dist, rw abs_le, split,
    {
      have eq1 : a + 1 = -(-(a + 1)) := by norm_num,
      have ineq1 := h2.2, conv_rhs at ineq1 {rw eq1}, rw le_neg at ineq1,
      have ineq2 := h1.1, have ineq3 := add_le_add ineq1 ineq2,
      have eq2 : -(a + 1) + (a - 1) = -2 := by ring,
      have eq3 : -x₂ + x₁ = x₁ - x₂ := by ring,
      conv_lhs at ineq3 {rw eq2},conv_rhs at ineq3 {rw eq3}, exact ineq3,
    },
    {
      have ineq1 := h1.2,
      have ineq2 := h2.1, have eq1 : x₂ = -(-x₂) := by norm_num,
      rw [eq1, le_neg] at ineq2, have ineq3 := add_le_add ineq1 ineq2,
      have eq2 : a + 1 + -(a - 1) = 2 := by ring, rw eq2 at ineq3,
      have eq3 : x₁ + -x₂ = x₁ - x₂ := by ring, rw eq3 at ineq3, exact ineq3,
    },
  }
end


-- This is should be the hardest part
/-
Lemma 1. Let α be an irrational number which is a root of f(x) = Σ aⱼ Xᶨ ∈ Z[x] with
f(x) ≢  0.

Then there is a constant A = A(α) > 0 such that 
  if a and b are integers with b > 0,
  then |α - a / b| > A / b^n
-/

def f_eval_on_ℝ (f : polynomial ℤ) (α : ℝ) : ℝ := (f.map ℤembℝ).eval α

theorem abs_f_eval_around_α_continuous (f : polynomial ℝ) (α : ℝ) : continuous_on (λ x : ℝ, (abs (f.eval x))) (set.Icc (α-1) (α+1)) :=
begin
  have H : (λ x : ℝ, (abs (f.eval x))) = abs ∘ (λ x, f.eval x),
  {
    exact rfl,
  },
  rw H,
  have H2 := polynomial.continuous_eval f,
  have H3 := continuous.comp real.continuous_abs H2,
  exact continuous.continuous_on H3
end

-- theorem f_nonzero_max_abs_f (f : polynomial ℝ) (f_nonzero : f ≠ 0) : ∃ 

-- private lemma f_eq_g_sum_f_eq_sum_g (f g : ℕ -> ℝ) (s : finset ℕ) : (∀ x ∈ s, f x = g x) -> (s.sum f) = (s.sum g) :=

private lemma same_coeff (f : polynomial ℤ) (n : ℕ): ℤembℝ (f.coeff n) = ((f.map ℤembℝ).coeff n) :=
begin
  simp, rw [polynomial.coeff_map], simp,
end

private lemma same_support (f : polynomial ℤ) : f.support = (f.map ℤembℝ).support :=
begin
  ext, split,
  {
    intro ha, replace ha : f.coeff a ≠ 0, exact finsupp.mem_support_iff.mp ha,
    have ineq1 : ℤembℝ (f.coeff a) ≠ 0, norm_num, exact ha,
    suffices : (polynomial.map ℤembℝ f).coeff a ≠ 0, exact finsupp.mem_support_iff.mpr this,
    rwa [polynomial.coeff_map],
  },
  {
    intro ha, replace ha : (polynomial.map ℤembℝ f).coeff a ≠ 0, exact finsupp.mem_support_iff.mp ha,
    rw [<-same_coeff] at ha,
    have ineq1 : f.coeff a ≠ 0,  simp at ha, exact ha,
    exact finsupp.mem_support_iff.mpr ineq1,
  }
end

-- private lemma same_function (f : polynomial ℤ) (a b : ℤ) (b_non_zero : b ≠ 0) : 
--   (λ (x : ℕ), (polynomial.map ℤembℝ f).coeff x * (↑a ^ x / ↑b ^ x)) =
--   (λ (x : ℕ), (1/b^f.nat_degree) * ((polynomial.map ℤembℝ f).coeff x * (↑a ^ x * ↑b ^ (f.nat_degree - x)))) :=
-- begin
--   ext, conv_rhs {
--     rw [mul_comm, mul_assoc],
--   }, 
--   suffices : ((a:ℝ) ^ x / (b:ℝ) ^ x) = (↑a ^ x * ↑b ^ (f.nat_degree - x) * (1 / ↑b ^ f.nat_degree)),
--   exact congr_arg (has_mul.mul ((polynomial.map ℤembℝ f).coeff x)) this,
--   have eq : (1 / ↑b ^ f.nat_degree) = (b:ℝ)^(-(f.nat_degree:ℤ)), norm_num,
--   rw div_eq_iff, simp,
--     conv_rhs {
--     rw [mul_assoc, mul_assoc, (mul_comm (↑b ^ (f.nat_degree - x))),
--     (mul_assoc (↑b ^ f.nat_degree)⁻¹), <-pow_add, <-nat.add_sub_assoc],
--   }, simp,
-- end

open_locale big_operators

private lemma sum_eq (S : finset ℕ) (f g : ℕ -> ℝ) : (∀ x ∈ S, f x = g x) -> S.sum f = S.sum g :=
begin
  intro h,
  have H := @finset.sum_congr _ _ S S f g _ _ h, exact H, refl,
end

-- set_option trace.simplify true

-- private lemma pow_div (b : ℝ) (hb : b ≠ 0) (m n : ℕ) : (b ^ m) / (b ^ n) = 1 / b ^ (n - m) :=
-- begin
--   sorry
-- end

-- set_option pp.all true

private lemma sum_a_pow_i_b_pow_n_sub_i (f : polynomial ℤ) (f_deg : f.nat_degree > 1) (a b : ℤ) (b_non_zero : b > 0) (a_div_b_not_root : (f.map ℤembℝ).eval (↑a/↑b) ≠ 0) :
  ∑ i in f.support, ((f.coeff i))*(a^i)*(b^(f.nat_degree - i)) ≠ 0 := sorry

theorem abs_f_at_p_div_q_ge_1_div_q_pow_n (f : polynomial ℤ) (f_deg : f.nat_degree > 1) (a b : ℤ) (b_non_zero : b > 0) (a_div_b_not_root : (f.map ℤembℝ).eval (↑a/↑b) ≠ 0) :
  abs ((f.map ℤembℝ).eval (↑a/↑b)) ≥ 1/(b^(f.nat_degree)) := -- sorry
begin
  have b_non_zero' : (b:ℝ) ≠ 0, norm_cast, linarith,
  have eq : ((f.map ℤembℝ).eval (↑a/↑b)) = (∑ n in f.support, ℤembℝ (f.coeff n) * ↑a^n/↑b^n),
  {
    rw [polynomial.eval, polynomial.eval₂, finsupp.sum], simp, rw <-same_support,
    rw sum_eq, intros n hn,
    have H : (@coe_fn (polynomial ℝ) polynomial.coeff_coe_to_fun (f.map ℤembℝ))= (f.map ℤembℝ).coeff,
    {
      exact rfl,
    },
    rw H, replace H : (polynomial.map ℤembℝ f).coeff n = ↑(f.coeff n),
    {
      rw polynomial.coeff_map, simp,
    },
    rw H, ring,
  },
  rw eq, simp,
  have eq2 : (∑ n in f.support, ℤembℝ (f.coeff n) * ↑a^n/↑b^n) = (∑ n in f.support, ((ℤembℝ (f.coeff n)) * (↑a^(n:ℤ) * ↑b^((f.nat_degree:ℤ)-n))) * (1/↑b^(f.nat_degree:ℤ))),
  {
    rw sum_eq, intros m hm,
    -- have H : (polynomial.map ℤembℝ f).coeff m = ↑(f.coeff m), rw polynomial.coeff_map, simp,
    -- simp only [eq,]
    conv_lhs {
      rw mul_div_assoc,
    },
    conv_rhs {rw mul_assoc},
    have eq3 := @mul_div_assoc ℝ _ (↑a ^ (m:ℤ) * ↑b ^ ((f.nat_degree:ℤ) - m)) 1 (↑b ^ (f.nat_degree:ℤ)),
    rw <-eq3,
    simp only [mul_one],
    conv_rhs {rw mul_div_assoc},
    have eq2 := (small_things.pow_sub_ℝ ↑b b_non_zero' f.nat_degree m), 
    conv_rhs {rw [eq2, div_div_eq_div_mul, (mul_comm (↑b ^ ↑m) (↑b ^ (f.nat_degree:ℤ))), <-div_div_eq_div_mul]},
    -- have H := @div_div_cancel ℝ _ ((b : ℝ) ^ (f.nat_degree:ℤ)) ((b:ℝ) ^ (m:ℤ)) _, rw H,
    have H := @div_self ℝ _ ((b:ℝ) ^ (f.nat_degree:ℤ)) _, rw [H],
    replace H := @mul_div_assoc ℝ _ ((a:ℝ) ^ (m:ℤ)) 1 ((b:ℝ) ^ (m:ℤ)), rw <-H, simp,

    have H := @pow_pos ℝ _ (b:ℝ) _ (f.nat_degree), have eq' : (b:ℝ) ^ (f.nat_degree:ℤ) = (b:ℝ) ^ f.nat_degree, simp, rw eq',
    linarith, norm_cast, exact b_non_zero,
  }, simp at eq2, rw eq2, rw [<-finset.sum_mul, mul_comm, abs_mul, abs_inv],
  have eq4 : abs ((b:ℝ)^ f.nat_degree) = (b:ℝ) ^ f.nat_degree, rw abs_of_pos, 
  have H := @pow_pos ℝ _ (b:ℝ) _ (f.nat_degree), exact H, norm_cast, assumption, rw eq4,
  have eq4 : abs (∑ (x : ℕ) in f.support, (f.coeff x:ℝ) * ((a:ℝ) ^ (x:ℤ) * (b:ℝ) ^ ((f.nat_degree:ℤ) - x))) = 
    (abs (∑ (x : ℕ) in f.support, (f.coeff x) * (a ^ (x:ℤ) * b ^ ((f.nat_degree:ℤ) - x))) : ℝ), simp,
  have eq5 : abs (∑ (x : ℕ) in f.support, (f.coeff x:ℝ) * ((a:ℝ) ^ x * (b:ℝ) ^ ((f.nat_degree:ℤ) - ↑x))) = 
    abs (∑ (x : ℕ) in f.support, (f.coeff x:ℝ) * ((a:ℝ) ^ (x:ℤ) * (b:ℝ) ^ ((f.nat_degree:ℤ) - ↑x))), norm_num, rw eq5, rw eq4,

  -- suffices ineq : 1 ≤ (abs (∑ (x : ℕ) in f.support, (f.coeff x) * (a ^ (x:ℤ) * b ^ ((f.nat_degree:ℤ) - x))) : ℝ),

  apply (le_mul_iff_one_le_right _).2, have eq6 := sum_a_pow_i_b_pow_n_sub_i f f_deg a b b_non_zero a_div_b_not_root,
  by_contra rid, simp at rid,
  -- the integer version
  have eq' : (abs (∑ (x : ℕ) in f.support, (f.coeff x) * (a ^ x * b ^ ((f.nat_degree) - x))):ℝ) = abs (∑ (x : ℕ) in f.support, (f.coeff x:ℝ) * ((a:ℝ) ^ x * (b:ℝ) ^ ((f.nat_degree:ℤ) - ↑x))),
  {
    -- rw sum_eq,
    sorry,
  },
  
  have rid' : abs (∑ (x : ℕ) in f.support, (f.coeff x) * (a ^ x * b ^ ((f.nat_degree) - x))) < 1,
  {
    suffices rid'' : ((abs (∑ (x : ℕ) in f.support, (f.coeff x) * (a ^ x * b ^ ((f.nat_degree) - x)))) : ℝ) < 1,
    norm_cast at rid'', sorry,
  },
  -- replace eq6 := abs_pos_iff.2 eq6, norm_cast,
  -- have eq6' : abs (∑ (i : ℕ) in f.support, f.coeff i * a ^ i * b ^ (f.nat_degree - i)) ≥ 1,
  -- {
  --   linarith,
  -- },
  -- have eq7 : abs (∑ (x : ℕ) in f.support, (f.coeff x:ℝ) * ((a:ℝ) ^ (x:ℤ) * ↑b ^ ((f.nat_degree:ℤ) - x))) = abs (∑ (x : ℕ) in f.support, ((f.coeff x) * (a ^ x * ↑b ^ (f.nat_degree - x)):ℝ)),
  -- rw sum_eq, intros i hi, simp,
  -- {
  --   have triv : ((f.nat_degree:ℤ) - ↑i) = (int.of_nat (f.nat_degree - (i:ℕ))), rw int.of_nat_sub, simp,
  --   have H := @polynomial.le_nat_degree_of_ne_zero ℤ i _ f _, exact H, rw finsupp.mem_support_iff at hi,
  --   rw polynomial.coeff, exact hi, rw triv, simp,
  -- },
  -- rw eq7,
  -- have eq8 : abs (∑ (x : ℕ) in f.support, ((f.coeff x) * (a ^ x * ↑b ^ (f.nat_degree - x))):ℝ) 
  --   = ((abs (∑ (x : ℕ) in f.support, (f.coeff x) * (a ^ x * ↑b ^ (f.nat_degree - x)))) : ℝ),
  -- {
  --   simp,
  -- },
  -- rw eq8,
  -- norm_cast,
  sorry,

  -- simp, have H := @pow_pos ℝ _ (b:ℝ) _ (f.nat_degree), exact H, norm_cast, assumption,
end

lemma about_irrational_root (α : real) (hα : irrational α) (f : polynomial ℤ) 
  (f_deg : f.nat_degree > 1) (α_root : f_eval_on_ℝ f α = 0) :
  ∃ A : real, ∀ a b : int, b > 0 -> abs(α - a / b) > (A / b ^ (f.nat_degree)) := -- sorry -- compiles in terminal but is very slow
begin
  have f_nonzero : f ≠ 0,
  {
    by_contra rid,
    simp at rid, have f_nat_deg_zero : f.nat_degree = 0, exact (congr_arg polynomial.nat_degree rid).trans rfl,
    rw f_nat_deg_zero at f_deg, linarith,
  },
  generalize hfℝ: f.map ℤembℝ = f_ℝ,
  have hfℝ_nonzero : f_ℝ ≠ 0,
  {
    by_contra absurd, simp at absurd, rw [polynomial.ext_iff] at absurd,
    have absurd2 : f = 0,
    {
      ext, replace absurd := absurd n, simp at absurd ⊢,
      rw [<-hfℝ, polynomial.coeff_map, ℤembℝ] at absurd,
      simp at absurd, exact absurd,
    },
    exact f_nonzero absurd2,
  },
  generalize hDf: f_ℝ.derivative = Df_ℝ,
  have H := compact.exists_forall_ge (@compact_Icc (α-1) (α+1)) 
              begin rw set.nonempty, use α, rw set.mem_Icc, split, linarith, linarith end
              (abs_f_eval_around_α_continuous Df_ℝ α),

  choose x_max hx_max using H,
  generalize M_def: abs (Df_ℝ.eval x_max) = M,
  have hM := hx_max.2, rw M_def at hM,
  have M_non_zero : M ≠ 0,
  {
    by_contra absurd,
    simp at absurd, rw absurd at hM,
    replace hM : ∀ (y : ℝ), y ∈ set.Icc (α - 1) (α + 1) → (polynomial.eval y Df_ℝ) = 0,
    {
      intros y hy,
      have H := hM y hy, simp at H, rw H,
    },
    replace hM : Df_ℝ = 0,
    {
      exact f_zero_on_interval_f_zero Df_ℝ hM,
    },
    rename hM Df_ℝ_zero,
    have f_ℝ_0 : f_ℝ.nat_degree = 0,
    {
      have H := small_things.zero_deriv_imp_const_poly_ℝ f_ℝ _, exact H,
      rw [<-hDf] at Df_ℝ_zero, assumption,
    },
    replace f_ℝ_0 := small_things.degree_0_constant f_ℝ f_ℝ_0,
    choose c hc using f_ℝ_0,
    -- f = c constant
    -- c must be 0 because f(α) = 0
    have absurd2 : c = 0,
    {
      rw [f_eval_on_ℝ, hfℝ, hc] at α_root, simp at α_root, assumption,
    },
    -- if c is zero contradiction to f_nonzero
    -- {
    rw absurd2 at hc,
    have f_zero : f = 0,
    {
      ext,
      have f_ℝ_n : f_ℝ.coeff n = 0, 
      have H := @polynomial.coeff_map _ _ _ f _ ℤembℝ n,
      rw [hfℝ, hc] at H, simp at H, 
      rw [<-hfℝ, @polynomial.coeff_map _ _ _ f _ ℤembℝ n], simp at H ⊢, norm_cast at H, exact eq.symm H,
      simp, rw [<-hfℝ, @polynomial.coeff_map _ _ _ f _ ℤembℝ n] at f_ℝ_n, simp at f_ℝ_n, assumption,
    },
    exact f_nonzero f_zero,
    
  },
  have M_pos : M > 0,
  {
    rw <-M_def at M_non_zero ⊢,
    have H := abs_pos_iff.2 M_non_zero, simp [abs_abs] at H, exact H,
  },
  generalize roots_def :  f_ℝ.roots = f_roots,
  generalize roots'_def : f_roots.erase α = f_roots', 
  generalize roots_distance_to_α : f_roots'.image (λ x, abs (α - x)) = distances,
  generalize hdistances' : insert (1/M) (insert (1:ℝ) distances) = distances',
  have hnon_empty: distances'.nonempty,
  {
    rw <-hdistances',
    rw [finset.nonempty], use (1/M), simp,
  },
  generalize hB : finset.min' distances' hnon_empty = B,
  have allpos : ∀ x : ℝ, x ∈ distances' -> x > 0,
  {
    intros x hx, rw [<-hdistances', finset.mem_insert, finset.mem_insert] at hx,
    cases hx,
    {
      -- 1 / M
      rw hx, simp, exact M_pos,
    },
    cases hx,
    {
      -- 1
      rw hx, exact zero_lt_one,
    },
    {
      -- x is abs (root - α) with root not α
      simp [<-roots_distance_to_α] at hx,
      choose α0 hα0 using hx,
      rw [<-roots'_def, finset.mem_erase] at hα0,
      rw <-(hα0.2), simp, apply (@abs_pos_iff ℝ _ (α - α0)).2,
      by_contra absurd, simp at absurd, rw sub_eq_zero_iff_eq at absurd,
      have absurd2 := hα0.1.1, exact f_nonzero (false.rec (f = 0) (absurd2 (eq.symm absurd))),
    },
  },
  have B_pos : B > 0,
  {
    have h := allpos (finset.min' distances' hnon_empty) (finset.min'_mem distances' hnon_empty),
    rw <-hB, assumption,
  },
  generalize hA : B / 2 = A,
  use A,
  by_contra absurd, simp at absurd,
  choose a ha using absurd,
  choose b hb using ha,


  have hb2 : b ^ f.nat_degree ≥ 1,
  {
    rw <-(pow_zero b),
    have hbge1 : b ≥ 1 := hb.1,
    have htrivial : 0 ≤ f.nat_degree := by exact bot_le,
    exact pow_le_pow hbge1 htrivial,
  },
  have hb21 : abs (α - a / b) ≤ A,
  {
    suffices H : (A / b ^ f.nat_degree) ≤ A,
    have H2 := hb.2, exact le_trans H2 H,
    apply (@div_le_iff ℝ _ A (b ^ f.nat_degree) A _).2,
    apply (@le_mul_iff_one_le_right ℝ _ (b ^ f.nat_degree) A _).2, norm_cast at hb2 ⊢, exact hb2,
    norm_cast, linarith, norm_cast, linarith,
  },
  have hb21' : abs (α - a / b) ≤ A / (b^f.nat_degree),
  {
    exact hb.2,
  },

  have hb22 : abs (α - a/b) < B,
  {
    have H := half_lt_self B_pos, rw hA at H, exact gt_of_gt_of_ge H hb21,
  },
  -- then a / b is in [α-1, α+1]
  have hab0 : (a/b:ℝ) ∈ set.Icc (α-1) (α+1),
  {
    suffices H : abs (α - a/b) ≤ 1, 
    have eq1 : ↑a / ↑b - α = - (α - ↑a / ↑b) := by norm_num,
    rw [<-closed_ball_Icc, metric.mem_closed_ball, real.dist_eq, eq1, abs_neg], exact H,
    suffices : B ≤ 1, linarith,
    rw <-hB, have ineq1 := finset.min'_le distances' hnon_empty 1 _, exact ineq1,
    rw [<-hdistances', finset.mem_insert, finset.mem_insert], right, left, refl,
  },
  -- a/b is not a root
  have hab1 : (↑a/↑b:ℝ) ≠ α,
  {
    have H := hα a b hb.1, rw sub_ne_zero at H, exact ne.symm H,
  },
  have hab2 : (↑a/↑b:ℝ) ∉ f_roots,
  {
    by_contra absurd,
    have H : ↑a/↑b ∈ f_roots',
    {
      rw [<-roots'_def, finset.mem_erase], exact ⟨hab1, absurd⟩,
    },
    have H2 : abs (α - ↑a/↑b) ∈ distances',
    {
      rw [<-hdistances', finset.mem_insert, finset.mem_insert], right, right,
      rw [<-roots_distance_to_α, finset.mem_image], use ↑a/↑b, split, exact H, refl,
    },
    have H3 := finset.min'_le distances' hnon_empty (abs (α - ↑a / ↑b)) H2,
    rw hB at H3, linarith,
  },
  -- either α > a/b or α < a/b, two cases essentially have the same proof
  have hab3 := ne_iff_lt_or_gt.1 hab1,
  cases hab3,
  {
    -- α > a/b subcase
    have H := exists_deriv_eq_slope (λ x, f_ℝ.eval x) hab3 _ _,
    choose x0 hx0 using H,
    have hx0l := hx0.1,
    have hx0r := hx0.2,
    -- clean hx0 a bit to be more usable,
    rw [polynomial.deriv, hDf, <-hfℝ] at hx0r,
    rw [f_eval_on_ℝ] at α_root, rw [α_root, hfℝ] at hx0r, simp at hx0r,
    -- we have Df(x0) ≠ 0
    have Df_x0_nonzero : Df_ℝ.eval x0 ≠ 0,
    {
      rw hx0r, intro rid, rw [neg_div, neg_eq_zero, div_eq_zero_iff] at rid,
      rw [<-roots_def, polynomial.mem_roots, polynomial.is_root] at hab2, exact hab2 rid,
      exact hfℝ_nonzero, linarith,
      -- sorry,
    },

    have H2 : abs(α - ↑a/↑b) = abs((f_ℝ.eval (↑a/↑b)) / (Df_ℝ.eval x0)),
    {
      norm_num [hx0r], 
      rw [neg_div, div_neg, abs_neg, div_div_cancel'],
      rw [<-roots_def] at hab2, by_contra absurd, simp at absurd,
      have H := polynomial.mem_roots _, rw polynomial.is_root at H,
      replace H := H.2 absurd, exact hab2 H,
      exact hfℝ_nonzero,
    },

    have ineq' : polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f) ≠ 0,
    {
      rw <-roots_def at hab2, intro rid, rw [hfℝ, <-polynomial.is_root, <-polynomial.mem_roots] at rid,
      exact hab2 rid, exact hfℝ_nonzero,
    },

    have ineq : abs (α - ↑a / ↑b) ≥ 1/(M*b^(f.nat_degree)),
    {
      rw [H2, abs_div],
      have ineq := abs_f_at_p_div_q_ge_1_div_q_pow_n f f_deg a b hb.1 ineq',
      rw [<-hfℝ],
      -- have ineq2 : abs (polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f)) / abs (polynomial.eval x0 Df_ℝ) > 1 / ↑b ^ f.nat_degree / abs (polynomial.eval x0 Df_ℝ),
      -- type_check @div_le_iff ℝ _ (abs (polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f))) (abs (polynomial.eval x0 Df_ℝ)),
      
      have ineq2 : abs (polynomial.eval x0 Df_ℝ) ≤ M,
      {
        have H := hM x0 _, exact H,
        have h1 := hx0.1,
        have h2 := @set.Ioo_subset_Icc_self ℝ _ (α-1) (α+1),
        have h3 := (@set.Ioo_subset_Ioo_iff ℝ _ _ (α-1) _ (α+1) _ hab3).2 _,
        have h4 : set.Ioo (↑a / ↑b) α ⊆ set.Icc (α-1) (α+1), exact set.subset.trans h3 h2,
        exact set.mem_of_subset_of_mem h4 h1, split,
        rw set.mem_Icc at hab0, exact hab0.1, linarith,
        -- sorry,
      },
      
      have ineq3 := small_things.a_ge_b_a_div_c_ge_b_div_c _ _ (abs (polynomial.eval x0 Df_ℝ)) ineq _ _,
      suffices ineq4 : 1 / ↑b ^ f.nat_degree / abs (polynomial.eval x0 Df_ℝ) ≥ 1 / (M * ↑b ^ f.nat_degree),
      {
        have ineq : abs (polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f)) / abs (polynomial.eval x0 Df_ℝ) ≥ 1 / (M * ↑b ^ f.nat_degree),
        linarith,
        exact ineq,
      },
      rw [div_div_eq_div_mul] at ineq3,
      have ineq4 : 1 / (↑b ^ f.nat_degree * abs (polynomial.eval x0 Df_ℝ)) ≥ 1 / (M * ↑b ^ f.nat_degree),
      {
        rw [ge_iff_le, one_div_le_one_div], conv_rhs {rw mul_comm}, 
        have ineq := ((@mul_le_mul_left ℝ _ (abs (polynomial.eval x0 Df_ℝ)) M (↑b ^ f.nat_degree)) _).2 ineq2, exact ineq,
        replace ineq := pow_pos hb.1 f.nat_degree, norm_cast, exact ineq, have ineq' : (b:ℝ) ^ f.nat_degree > 0, norm_cast,
        exact pow_pos hb.1 f.nat_degree, exact (mul_pos M_pos ineq'),
        apply mul_pos, norm_cast, exact pow_pos hb.1 f.nat_degree, rw abs_pos_iff, exact Df_x0_nonzero,
      },
      rw div_div_eq_div_mul, exact ineq4, have ineq5 := @div_nonneg ℝ _ 1 (↑b ^ f.nat_degree) _ _, exact ineq5, norm_cast,
      exact bot_le, norm_cast, exact pow_pos hb.1 f.nat_degree, rw [gt_iff_lt, abs_pos_iff], exact Df_x0_nonzero,
    },

    have ineq2 : 1/(M*b^(f.nat_degree)) > A / (b^f.nat_degree),
    {
      have ineq : A < B, rw [<-hA], exact @half_lt_self ℝ _ B B_pos,
      have ineq2 : B ≤ 1/M, rw [<-hB], have H := finset.min'_le distances' hnon_empty (1/M) _, exact H,
      rw [<-hdistances', finset.mem_insert], left, refl,
      have ineq3 : A < 1/M, linarith,
      rw [<-div_div_eq_div_mul], have ineq' := (@div_lt_div_right ℝ _ A (1/M) (↑b ^ f.nat_degree) _).2 ineq3,
      rw <-gt_iff_lt at ineq', exact ineq', norm_cast, exact pow_pos hb.1 f.nat_degree,
    },
    -- hb21 : abs (α - ↑a / ↑b) ≤ A,
    have ineq3 : abs (α - a / b) > A / b ^ f.nat_degree,
    {
      linarith,
    },
    have ineq4 : abs (α - a / b) > abs (α - a / b), {linarith}, linarith,


    -- continuity
    {
      exact @polynomial.continuous_on ℝ _ (set.Icc (↑a / ↑b) α) f_ℝ,
    },

    -- differentiable
    {
      exact @polynomial.differentiable_on ℝ _ (set.Ioo (↑a / ↑b) α) f_ℝ,
    },
  },

  {
    -- α < a/b subcase
    have H := exists_deriv_eq_slope (λ x, f_ℝ.eval x) hab3 _ _,
    choose x0 hx0 using H,
    have hx0l := hx0.1,
    have hx0r := hx0.2,
    -- clean hx0 a bit to be more usable,
    rw [polynomial.deriv, hDf, <-hfℝ] at hx0r,
    rw [f_eval_on_ℝ] at α_root, rw [α_root, hfℝ] at hx0r, simp at hx0r,
    -- we have Df(x0) ≠ 0
    have Df_x0_nonzero : Df_ℝ.eval x0 ≠ 0,
    {
      rw hx0r, intro rid, rw [div_eq_zero_iff] at rid,
      rw [<-roots_def, polynomial.mem_roots, polynomial.is_root] at hab2, exact hab2 rid,
      exact hfℝ_nonzero, linarith,
      -- sorry,
    },

    have H2 : abs(α - ↑a/↑b) = abs((f_ℝ.eval (↑a/↑b)) / (Df_ℝ.eval x0)),
    {
      norm_num [hx0r], 
      rw [div_div_cancel'], have : ↑a / ↑b - α = - (α - ↑a / ↑b), linarith, rw [this, abs_neg],
      by_contra absurd, simp at absurd,
      have H := polynomial.mem_roots _, rw polynomial.is_root at H,
      replace H := H.2 absurd, rw roots_def at H, exact hab2 H,
      exact hfℝ_nonzero,
    },

    have ineq' : polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f) ≠ 0,
    {
      rw <-roots_def at hab2, intro rid, rw [hfℝ, <-polynomial.is_root, <-polynomial.mem_roots] at rid,
      exact hab2 rid, exact hfℝ_nonzero,
    },

    have ineq : abs (α - ↑a / ↑b) ≥ 1/(M*b^(f.nat_degree)),
    {
      rw [H2, abs_div],
      have ineq := abs_f_at_p_div_q_ge_1_div_q_pow_n f f_deg a b hb.1 ineq',
      rw [<-hfℝ],
      -- have ineq2 : abs (polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f)) / abs (polynomial.eval x0 Df_ℝ) > 1 / ↑b ^ f.nat_degree / abs (polynomial.eval x0 Df_ℝ),
      -- type_check @div_le_iff ℝ _ (abs (polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f))) (abs (polynomial.eval x0 Df_ℝ)),
      
      have ineq2 : abs (polynomial.eval x0 Df_ℝ) ≤ M,
      {
        have H := hM x0 _, exact H,
        have h1 := hx0.1,
        have h2 := @set.Ioo_subset_Icc_self ℝ _ (α-1) (α+1),
        have h3 := (@set.Ioo_subset_Ioo_iff ℝ _ _ (α-1) _ (α+1) _ hab3).2 _,
        have h4 : set.Ioo α (↑a / ↑b) ⊆ set.Icc (α-1) (α+1), exact set.subset.trans h3 h2,
        exact set.mem_of_subset_of_mem h4 h1, split,
        rw set.mem_Icc at hab0, linarith,
        exact (set.mem_Icc.1 hab0).2,
        -- sorry,
      },
      
      have ineq3 := small_things.a_ge_b_a_div_c_ge_b_div_c _ _ (abs (polynomial.eval x0 Df_ℝ)) ineq _ _,
      suffices ineq4 : 1 / ↑b ^ f.nat_degree / abs (polynomial.eval x0 Df_ℝ) ≥ 1 / (M * ↑b ^ f.nat_degree),
      {
        have ineq : abs (polynomial.eval (↑a / ↑b) (polynomial.map ℤembℝ f)) / abs (polynomial.eval x0 Df_ℝ) ≥ 1 / (M * ↑b ^ f.nat_degree),
        linarith,
        exact ineq,
      },
      rw [div_div_eq_div_mul] at ineq3,
      have ineq4 : 1 / (↑b ^ f.nat_degree * abs (polynomial.eval x0 Df_ℝ)) ≥ 1 / (M * ↑b ^ f.nat_degree),
      {
        rw [ge_iff_le, one_div_le_one_div], conv_rhs {rw mul_comm}, 
        have ineq := ((@mul_le_mul_left ℝ _ (abs (polynomial.eval x0 Df_ℝ)) M (↑b ^ f.nat_degree)) _).2 ineq2, exact ineq,
        replace ineq := pow_pos hb.1 f.nat_degree, norm_cast, exact ineq, have ineq' : (b:ℝ) ^ f.nat_degree > 0, norm_cast,
        exact pow_pos hb.1 f.nat_degree, exact (mul_pos M_pos ineq'),
        apply mul_pos, norm_cast, exact pow_pos hb.1 f.nat_degree, rw abs_pos_iff, exact Df_x0_nonzero,
      },
      rw div_div_eq_div_mul, exact ineq4, have ineq5 := @div_nonneg ℝ _ 1 (↑b ^ f.nat_degree) _ _, exact ineq5, norm_cast,
      exact bot_le, norm_cast, exact pow_pos hb.1 f.nat_degree, rw [gt_iff_lt, abs_pos_iff], exact Df_x0_nonzero,
    },

    have ineq2 : 1/(M*b^(f.nat_degree)) > A / (b^f.nat_degree),
    {
      have ineq : A < B, rw [<-hA], exact @half_lt_self ℝ _ B B_pos,
      have ineq2 : B ≤ 1/M, rw [<-hB], have H := finset.min'_le distances' hnon_empty (1/M) _, exact H,
      rw [<-hdistances', finset.mem_insert], left, refl,
      have ineq3 : A < 1/M, linarith,
      rw [<-div_div_eq_div_mul], have ineq' := (@div_lt_div_right ℝ _ A (1/M) (↑b ^ f.nat_degree) _).2 ineq3,
      rw <-gt_iff_lt at ineq', exact ineq', norm_cast, exact pow_pos hb.1 f.nat_degree,
    },
    -- hb21 : abs (α - ↑a / ↑b) ≤ A,
    have ineq3 : abs (α - a / b) > A / b ^ f.nat_degree,
    {
      linarith,
    },
    have ineq4 : abs (α - a / b) > abs (α - a / b), {linarith}, linarith,


    -- continuity
    {
      exact @polynomial.continuous_on ℝ _ (set.Icc α (↑a / ↑b)) f_ℝ,
    },

    -- differentiable
    {
      exact @polynomial.differentiable_on ℝ _ (set.Ioo α (↑a / ↑b)) f_ℝ,
    },
  },

end



lemma liouville_numbers_irrational: ∀ (x : real), (liouville_number x) -> irrational x :=
begin
  intros x li_x a b hb rid, replace rid : x = ↑a / ↑b, linarith,
  rw liouville_number at li_x,
  generalize hn : b.nat_abs + 1 = n,
  have b_ineq : 2 ^ (n-1) > b,
  {
    rw <-hn, simp,
    have triv : b = b.nat_abs, rw <-int.abs_eq_nat_abs, rw abs_of_pos, assumption,rw triv, simp,
    have H := @nat.lt_pow_self 2 _ b.nat_abs,  norm_cast, exact H, exact lt_add_one 1,
  },
  choose p hp using li_x n,
  choose q hq using hp, rw rid at hq,
  have q_pos : q > 0, linarith,
  rw div_sub_div at hq, swap, norm_cast, linarith, swap, norm_cast, have hq1 := hq.1, linarith,
  rw abs_div at hq,
  
  by_cases (abs ((a:ℝ) * (q:ℝ) - (b:ℝ) * (p:ℝ)) = 0),
  {
    -- aq = bp,
    rw h at hq, simp at hq, have hq1 := hq.1, have hq2 := hq.2, have hq21 := hq2.1, have hq22 := hq2.2, linarith,
  },
  {
    -- |a q - b p| ≠ 0,
    -- then |aq-bp| ≥ 1
    -- type_check @abs ℤ _,
    have ineq : ((@abs ℤ _ (a * q - b * p)):ℝ) = abs ((a:ℝ) * (q:ℝ) - (b:ℝ) * (p:ℝ)), norm_cast,
    have ineq2: (abs (a * q - b * p)) ≠ 0, by_contra rid, simp at rid, rw rid at ineq, simp at ineq, exact h (eq.symm ineq),
    have ineq2':= abs_pos_iff.2 ineq2, rw [abs_abs] at ineq2',
    replace ineq2' : 1 ≤ abs (a * q - b * p), linarith,
    have ineq3 : 1 ≤ @abs ℝ _ (a * q - b * p), norm_cast, exact ineq2',

    have eq : abs (↑b * ↑q) = (b:ℝ)*(q:ℝ), rw abs_of_pos, have eq' := mul_pos hb q_pos, norm_cast, exact eq',
    rw eq at hq,
    have ineq4 : 1 / (b * q : ℝ) ≤ (@abs ℝ _ (a * q - b * p)) / (b * q), 
    {
      rw div_le_div_iff, simp, have H := (@le_mul_iff_one_le_left ℝ _ _ (b * q) _).2 ineq3, exact H,
      norm_cast, have eq' := mul_pos hb q_pos, exact eq', norm_cast, have eq' := mul_pos hb q_pos, exact eq', norm_cast, have eq' := mul_pos hb q_pos, exact eq',
    },
    have b_ineq' := @mul_lt_mul ℤ _ b q (2^(n-1)) q b_ineq _ _ _,
    have b_ineq'' : (b * q : ℝ) < (2:ℝ) ^ (n-1) * (q : ℝ), norm_cast, simp, exact b_ineq',
    
    have q_ineq1 : q ≥ 2, linarith,
    have q_ineq2 := @pow_le_pow_of_le_left ℤ _ 2 q _ _ (n-1),
    have q_ineq3 : 2 ^ (n - 1) * q ≤ q ^ (n - 1) * q, rw (mul_le_mul_right _), assumption, linarith, 
    have triv : q ^ (n - 1) * q = q ^ n, rw <-hn, simp, rw pow_add, simp, rw triv at q_ineq3,

    have b_ineq2 : b * q < q ^ n, linarith,
    have rid' := (@one_div_lt_one_div ℝ _ (q^n) (b*q) _ _).2 _,
    have rid'' : @abs ℝ _ (a * q - b * p) / (b * q : ℝ) > 1 / q ^ n, linarith,
    have hq1 := hq.1, have hq2 := hq.2, have hq21 := hq2.1, have hq22 := hq2.2,
    linarith,

    -- other less important steps
    norm_cast, apply pow_pos, linarith,
    norm_cast, apply mul_pos, linarith, linarith,
    norm_cast, assumption,
    linarith,
    assumption,
    linarith,
    linarith,
    apply pow_nonneg, linarith,
  },
  done
  -- sorry,
end



theorem liouville_numbers_transcendental : ∀ x : real, liouville_number x -> ¬(is_algebraic ℤ x) := 
begin
  intros x li_x,
  have irr_x : irrational x, exact liouville_numbers_irrational x li_x,
  intros rid, rw is_algebraic at rid,
  choose f hf using rid,
  have f_deg : f.nat_degree > 1,
  {
    by_contra rid, simp at rid, replace rid := lt_or_eq_of_le rid, cases rid,
    {
      replace rid : f.nat_degree = 0, linarith, rw polynomial.nat_degree_eq_zero_iff_degree_le_zero at rid, rw polynomial.degree_le_zero_iff at rid,
      rw rid at hf, simp at hf, have hf1 := hf.1, have hf2 := hf.2,rw hf2 at hf1, simp at hf1, exact hf1,
    },
    {
      have f_eq : f = polynomial.C (f.coeff 0) + (polynomial.C (f.coeff 1)) * polynomial.X,
      {
        ext, by_cases (n ≤ 1),
        {
          replace h := lt_or_eq_of_le h, cases h,
          {
            replace h : n = 0, linarith, rw h, simp,
          },
          {
            rw h, simp, rw polynomial.coeff_C, split_ifs, exfalso, linarith, simp,
          },
        },
        {
          simp at h,simp, have deg : f.nat_degree < n, linarith,
          have z := polynomial.coeff_eq_zero_of_nat_degree_lt deg, rw z, rw polynomial.coeff_X,
          split_ifs, exfalso, linarith, simp, rw polynomial.coeff_C,
          split_ifs, exfalso, linarith, refl,
        }
      },

      rw f_eq at hf, simp at hf, rw irrational at irr_x,
      by_cases ((f.coeff 1) > 0),
      {
        replace irr_x := irr_x (-(f.coeff 0)) (f.coeff 1) h, simp at irr_x, rw neg_div at irr_x, rw sub_neg_eq_add at irr_x, rw add_comm at irr_x,
        suffices suff : ↑(f.coeff 0) / ↑(f.coeff 1) + x = 0, exact irr_x suff,
        rw add_eq_zero_iff_eq_neg, rw div_eq_iff, have triv : -x * ↑(f.coeff 1) = - (x * (f.coeff 1)), exact norm_num.mul_neg_pos x ↑(polynomial.coeff f 1) (x * ↑(polynomial.coeff f 1)) rfl,
        rw triv, rw <-add_eq_zero_iff_eq_neg, rw mul_comm, exact hf.2,
        intro rid',norm_cast at rid', rw <-rid at rid', rw <-polynomial.leading_coeff at rid',
        rw polynomial.leading_coeff_eq_zero at rid', rw polynomial.ext_iff at rid', simp at rid', replace rid' := rid' 1, linarith,
      },
      {
        simp at h, replace h := lt_or_eq_of_le h, cases h,
        {

         replace irr_x := irr_x (f.coeff 0) (-(f.coeff 1)) _, simp at irr_x, rw div_neg at irr_x, rw sub_neg_eq_add at irr_x, rw add_comm at irr_x,
          suffices suff : ↑(f.coeff 0) / ↑(f.coeff 1) + x = 0, exact irr_x suff,
          rw add_eq_zero_iff_eq_neg, rw div_eq_iff, have triv : -x * ↑(f.coeff 1) = - (x * (f.coeff 1)), exact norm_num.mul_neg_pos x ↑(polynomial.coeff f 1) (x * ↑(polynomial.coeff f 1)) rfl,
          rw triv, rw <-add_eq_zero_iff_eq_neg, rw mul_comm, exact hf.2,
          intro rid',norm_cast at rid', rw <-rid at rid', rw <-polynomial.leading_coeff at rid',
          rw polynomial.leading_coeff_eq_zero at rid', rw polynomial.ext_iff at rid', simp at rid', replace rid' := rid' 1, linarith, 
          linarith,
        },
        rw <-rid at h,
        rw <-polynomial.leading_coeff at h,
          rw polynomial.leading_coeff_eq_zero at h, rw h at rid, simp at rid, exact rid,
      }
    },

  },
  have about_root : f_eval_on_ℝ f x = 0,
  {
    rw f_eval_on_ℝ, have H := hf.2, rw [polynomial.aeval_def] at H,
    rw [polynomial.eval, polynomial.eval₂_map], rw [polynomial.eval₂, finsupp.sum] at H ⊢, rw [<-H, sum_eq],  
    -- rw <-H, rw sum_eq,
    intros m hm, simp,
  },

  choose A hA using about_irrational_root x irr_x f f_deg about_root,
end


-- define an example of Liouville number Σᵢ 1/2^(i!)

-- function n -> 1/2^n! 
def two_pow_n_fact_inverse (n : nat) : real := (1/2)^n.fact
-- function n -> 1/2^n
def two_pow_n_inverse (n : nat) : real := (1/2)^n

lemma two_pow_n_fact_inverse_ge_0 (n : nat) : two_pow_n_fact_inverse n ≥ 0 :=
begin
    unfold two_pow_n_fact_inverse,
    simp, have h := le_of_lt (@pow_pos _ _ (2:real) _ n.fact),
    norm_cast at h ⊢, exact h, norm_num, done
end

lemma useless_elsewhere : ∀ n : nat, n ≤ n.fact
| 0                         := by norm_num
| 1                         := by norm_num
| (nat.succ (nat.succ n))   := begin 
    have H := useless_elsewhere n.succ,
    conv_rhs {rw (nat.fact_succ n.succ)},
    have ineq1 : n.succ.succ * n.succ ≤ n.succ.succ * n.succ.fact, {exact nat.mul_le_mul_left (nat.succ (nat.succ n)) (useless_elsewhere (nat.succ n))},
    suffices ineq2 : n.succ.succ ≤ n.succ.succ * n.succ, {exact nat.le_trans ineq2 ineq1},
    have H' : ∀ m : nat, m.succ.succ ≤ m.succ.succ * m.succ,
    {
        intro m, induction m with m hm,
        norm_num,
        simp [nat.succ_mul, nat.mul_succ, nat.succ_eq_add_one] at hm ⊢,
    },
    exact H' n,
end

lemma useless_elsewhere2 : 2 ≠ 0 := by norm_num

lemma two_pow_n_fact_inverse_le_two_pow_n_inverse (n : nat) : two_pow_n_fact_inverse n ≤ two_pow_n_inverse n :=
begin
  unfold two_pow_n_fact_inverse,
  unfold two_pow_n_inverse, simp,
  by_cases (n = 0),
  -- if n is 0
  rw h, simp, norm_num,
  -- if n > 0
  have n_pos : n > 0 := by exact bot_lt_iff_ne_bot.mpr h,
  have H := (@inv_le_inv ℝ _ (2 ^ n.fact) (2 ^ n) _ _).2 _, exact H,
  have H := @pow_pos ℝ _ 2 _ n.fact,  exact H, exact two_pos,
  have H := @pow_pos ℝ _ 2 _ n, exact H, exact two_pos,
  have H := @pow_le_pow ℝ _ 2 n n.fact _ _, exact H, norm_num, exact useless_elsewhere n,
end

-- Σᵢ 1/2ⁱ exists
theorem summable_two_pow_n_inverse : summable two_pow_n_inverse :=
begin
  exact summable_geometric_two,
end

-- Hence Σᵢ 1/2^i! exists by comparison test
theorem summable_two_pow_n_fact_inverse : summable two_pow_n_fact_inverse :=
begin
  exact @summable_of_nonneg_of_le _ two_pow_n_inverse two_pow_n_fact_inverse two_pow_n_fact_inverse_ge_0 two_pow_n_fact_inverse_le_two_pow_n_inverse summable_two_pow_n_inverse,
end

-- define α to be Σᵢ 1/2^i!
def α := classical.some summable_two_pow_n_fact_inverse

-- Then α is a Liouville number hence a transcendental number.
theorem liouville_α : liouville_number α :=
begin
  intro n,
  sorry
end

theorem transcendental_α : transcendental α := liouville_numbers_transcendental α liouville_α

