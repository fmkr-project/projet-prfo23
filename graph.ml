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
<<<<<<< HEAD
                                   (* Implémentation partielle : on n'a pas besoin de supprimer des arêtes *)
  val print_succs: vx -> t -> unit
  val print_graph: t -> unit
=======
      (* Implémentation partielle : on n'a pas besoin de supprimer des arêtes *)
>>>>>>> c2baf921e8a4451c22419725097f1fc63a7ab573
  
end;;


module StrGraph = struct
  type vx = String.t
  module NodeSet = Set.Make(String)
  module MapsTo = Map.Make(String)
  type t = NodeSet.t MapsTo.t

  (* Basic graph functions *)
  let empty = MapsTo.empty
  let is_empty g = g = empty
  let add_vx a g =
    if MapsTo.mem a g then g else MapsTo.add a NodeSet.empty g
  let add_edge s d g =
    (* Add s & d if they do not exist
       On considère le graphe orienté *)
    let g = add_vx s (add_vx d g) in
    MapsTo.add s (NodeSet.add d (MapsTo.find s g)) g
  
  (* DEBUG - Display functions *)
  let print_succs elt g =
    (* print_succs: vx -> t -> unit *)
    let succs = MapsTo.find elt g in
    begin Printf.printf "[";
          NodeSet.fold (fun item () -> Printf.printf "%s, " item) succs ();
          Printf.printf "]\n" end
  
  let print_graph g =
    (* print_graph: t -> unit *)
    MapsTo.fold (fun elt _ () -> begin Printf.printf "%s: " elt;
                                       print_succs elt g;
<<<<<<< HEAD
                                       Printf.printf "\n" end)
      g ()
  
  (* Fonctions de parcours *)
=======
                                       Printf.printf "\n" end) g ()
>>>>>>> c2baf921e8a4451c22419725097f1fc63a7ab573
  
end;;
