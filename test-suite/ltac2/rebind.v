Require Import Ltac2.Ltac2 Ltac2.Notations.

Ltac2 mutable foo () := constructor.

Goal True.
Proof.
foo ().
Qed.

Ltac2 Set foo := fun _ => fail.

Goal True.
Proof.
Fail foo ().
constructor.
Qed.

(** Not the right type *)
Fail Ltac2 Set foo := 0.

Ltac2 bar () := ().

(** Cannot redefine non-mutable tactics *)
Fail Ltac2 Set bar := fun _ => ().

(** Subtype check *)

Ltac2 mutable rec f x := f x.

Fail Ltac2 Set f := fun x => x.

Ltac2 mutable g x := x.

Ltac2 Set g := f.

(* Rebinding with old values *)

Ltac2 mutable qux () := Message.print (Message.of_string "Hello").

Ltac2 Set qux as self := fun () => self (); self ().

Ltac2 Eval qux ().

Ltac2 Type rec nat := [O | S (nat)].

Ltac2 mutable quz := O.

Ltac2 Set quz as self := S self.

Ltac2 Eval quz.
