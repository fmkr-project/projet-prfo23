module type S = sig
  (* Vertices type *)
  type vx
  (* Type to store nodes *)
  module NodeSet:Set.S
  (* Graph type *)
  type t

  val empty: t
  val is_empty: t -> bool
  val add_vx: vx -> t -> t
  val add_edge: vx -> vx -> int -> t -> t
      (* Implémentation partielle : on n'a pas besoin de supprimer des arêtes *)
  val print_succs: vx -> t -> unit
  val print_graph: t -> unit

  val shortests: vx -> vx -> t -> string list list
  exception Inaccessible
  val print_paths: string list list -> unit
end;;

module type F = sig
  type vx
  module NodeSet:Set.S
  module Weighted:S
  type t

  val empty: t
  val is_empty: t -> bool
  val add_vx: vx -> t -> t
  val add_edge: vx -> vx -> int -> int -> t -> t
  val build_residual: t -> Weighted.t
  val max_flow: string -> t -> int
  val used_edges: t -> int
  
  (* Display *)
  val print_residual: t -> unit
  val print_flow: t -> unit
  val print_used_edges: t -> unit

  
  val dinitz: vx -> vx -> t -> t
end

  
module FlowGraph: F with type vx = string
module WStrGraph: S with type vx = string
