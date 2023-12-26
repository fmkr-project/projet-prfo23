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
  val print_succs: vx -> t -> unit
  val print_graph: t -> unit
  val shortests: vx -> vx -> t -> string list list
  val print_paths: string list list -> unit
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
                                       Printf.printf "\n" end)
      g ()


  (* Fonctions d'affichage *)
  (* Affichage d'un seul chemin a l'ecran *)
  (* print_path : vx list -> unit *)
  (* TODO : format correct *)
  let print_path path =
    let rec printable li = match li with
      | [] -> ""
      | hd::tl -> (printable tl) ^ hd ^ " "
    in Printf.printf "%s\n" (printable path)

  (* print_paths : vx list list -> unit *)
  let rec print_paths paths = match paths with
    | [] -> ()
    | hd::tl -> begin print_path hd; print_paths tl end
  
  
  (* Fonctions de parcours *)
  (* nexts : vx -> t -> vx list *)
  let nexts from g = if not (MapsTo.mem from g)
                     then raise Not_found
                     else NodeSet.elements (MapsTo.find from g)

  (* Les paths sont stockés dans l'autre sens *)
  (* Pour chaque chemin de paths, ajouter ce chemin plus un successeur pour chaque successeur dans g possede par le dernier Node du chemin *)
  (* esc : vx list list -> t -> vx list list *)
  let rec esc paths g = match paths with
    | [] -> []
    | hd::tl ->
       let hd_path_succs = try nexts (List.hd hd) g
                           with Not_found -> []
       in
       let new_hd =
         List.map (fun succ -> succ::hd) hd_path_succs
       in new_hd @ (esc tl g)
       

  let ends paths = List.map List.hd paths
  
  (* TODO gérer le cas des graphes avec cycle *)
  (* Chemin le + court = on s'arrête le plus tôt possible *)
  let shortests src dst g =
    let rec check_for_dst acc = if List.mem dst (ends acc)
                                then List.filter (fun elt -> List.hd elt = dst) acc
                                else check_for_dst (esc acc g)
    in check_for_dst [[src]]


end;;
