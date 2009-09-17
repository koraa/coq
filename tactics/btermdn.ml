(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, * CNRS-Ecole Polytechnique-INRIA Futurs-Universite Paris Sud *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(* $Id$ *)

open Term
open Names
open Termdn
open Pattern
open Libnames

(* Discrimination nets with bounded depth.
   See the module dn.ml for further explanations.
   Eduardo (5/8/97). *)

let dnet_depth = ref 8

let bounded_constr_pat_discr_st st (t,depth) =
  if depth = 0 then
    None
  else
    match constr_pat_discr_st st t with
      | None -> None
      | Some (c,l) -> Some(c,List.map (fun c -> (c,depth-1)) l)

let bounded_constr_val_discr_st st (t,depth) =
  if depth = 0 then
    Dn.Nothing
  else
    match constr_val_discr_st st t with
      | Dn.Label (c,l) -> Dn.Label(c,List.map (fun c -> (c,depth-1)) l)
      | Dn.Nothing -> Dn.Nothing
      | Dn.Everything -> Dn.Everything

let bounded_constr_pat_discr (t,depth) =
  if depth = 0 then
    None
  else
    match constr_pat_discr t with
      | None -> None
      | Some (c,l) -> Some(c,List.map (fun c -> (c,depth-1)) l)

let bounded_constr_val_discr (t,depth) =
  if depth = 0 then
    Dn.Nothing
  else
    match constr_val_discr t with
      | Dn.Label (c,l) -> Dn.Label(c,List.map (fun c -> (c,depth-1)) l)
      | Dn.Nothing -> Dn.Nothing
      | Dn.Everything -> Dn.Everything

type 'a t = (global_reference,constr_pattern * int,'a) Dn.t

let create = Dn.create

let add = function
  | None ->
      (fun dn (c,v) ->
	Dn.add dn bounded_constr_pat_discr ((c,!dnet_depth),v))
  | Some st ->
      (fun dn (c,v) ->
	Dn.add dn (bounded_constr_pat_discr_st st) ((c,!dnet_depth),v))

let rmv = function
  | None ->
      (fun dn (c,v) ->
	Dn.rmv dn bounded_constr_pat_discr ((c,!dnet_depth),v))
  | Some st ->
      (fun dn (c,v) ->
	Dn.rmv dn (bounded_constr_pat_discr_st st) ((c,!dnet_depth),v))

let lookup = function
  | None ->
      (fun dn t ->
	List.map
	  (fun ((c,_),v) -> (c,v))
	  (Dn.lookup dn bounded_constr_val_discr (t,!dnet_depth)))
  | Some st ->
      (fun dn t ->
	List.map
	  (fun ((c,_),v) -> (c,v))
	  (Dn.lookup dn (bounded_constr_val_discr_st st) (t,!dnet_depth)))

let app f dn = Dn.app (fun ((c,_),v) -> f(c,v)) dn

