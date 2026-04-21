import Mathlib.Data.Nat.Basic

/-- For all natural numbers a, b, c, we have (a + b) + c = (a + c) + b.
    Proof follows: associativity → commutativity of b, c → associativity. -/
theorem nat_add_comm_generalized (a b c : ℕ) : (a + b) + c = (a + c) + b := by
  rw [Nat.add_assoc, Nat.add_comm b c, ← Nat.add_assoc]

-- Alternative: automatic proof via omega
theorem nat_add_comm_generalized' (a b c : ℕ) : (a + b) + c = (a + c) + b := by
  omega
