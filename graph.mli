module type S = sig
  (* Vertices type *)
  type vx
  (* Type to store nodes *)
  module NodeSet:Set.S with type elt = vx
  (* Graph type *)
  type t

  val empty: t
  val is_empty: t -> bool
  val add_vx: vx -> t -> t
  val add_edge: vx -> vx -> t -> t
      (* Implémentation partielle : on n'a pas besoin de supprimer des arêtes *)
  
end;;

module StrGraph: S
