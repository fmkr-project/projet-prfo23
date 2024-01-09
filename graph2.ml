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
  (* Flow graphs *)
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
  
  val print_residual: t -> unit
  val print_flow: t -> unit
  val print_used_edges: t -> unit
  
  val dinitz: vx -> vx -> t -> t
end


module WStrGraph = struct
  type vx = String.t
  module NodeSet = Set.Make(struct
                               type t = string*int
                               let compare = compare
                             end)
  module MapsTo = Map.Make(String)
  type t = NodeSet.t MapsTo.t

  (* Basic graph functions *)
  let empty = MapsTo.empty
  let is_empty g = g = empty
  let add_vx a g =
    if MapsTo.mem a g then g else MapsTo.add a NodeSet.empty g
  let add_edge s d w g =
    (* Add s & d if they do not exist
       On considère le graphe orienté *)
    let g = add_vx s (add_vx d g) in
    if w <= 0 then g else
    MapsTo.add s (NodeSet.add (d,w) (MapsTo.find s g)) g
  
  (* DEBUG - Display functions *)
  let print_succs elt g =
    (* print_succs: vx -> t -> unit *)
    let succs = MapsTo.find elt g in
    begin Printf.printf "[";
          NodeSet.fold (fun (vx,w) () -> Printf.printf "%s (%d), " vx w) succs ();
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
                     else
                       let weighted_nexts = MapsTo.find from g in
                       NodeSet.fold (fun (elt,w) acc -> elt::acc) weighted_nexts []

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

  let min_weight path g =
  (* val min_weight: string list -> t -> t *)
  (* Return the weight of the edge with the minimal weight along the path *)
    let rec weight_aux path g = match path with
      |[] -> Int.max_int
      |[hd] -> Int.max_int
      |dst::src::tl ->
        let nexts = MapsTo.find src g in
        let current_w = NodeSet.fold
                          (fun (d,w) acc -> if d = dst then w else acc) nexts 0         
        in let next_w = weight_aux (src::tl) g
           in if current_w > next_w then next_w else current_w
    in weight_aux path g
 
  exception Inaccessible
  
  (* TODO gérer le cas des graphes avec cycle *)
  (* Chemin le + court = on s'arrête le plus tôt possible *)
  let shortests src dst g =
    (* chemin de longueur maximale |V| *)
    let max_iterations = MapsTo.cardinal g in
    let rec check_for_dst acc iter =
      if iter > max_iterations then raise Inaccessible
      else
        if List.mem dst (ends acc)
        then List.filter (fun elt -> List.hd elt = dst) acc
        else check_for_dst (esc acc g) (iter+1)
    in check_for_dst [[src]] 0


end;;





module FlowGraph = struct
  type vx = String.t
  module NodeSet = Set.Make(struct
                           type t = string*int*int
                           let compare = compare
                         end)
  module MapsTo = Map.Make(String)
  module Weighted = WStrGraph
  type t = NodeSet.t MapsTo.t

  let empty = MapsTo.empty
  let is_empty g = g = empty
  let add_vx a g = if MapsTo.mem a g then g else MapsTo.add a NodeSet.empty g
  let add_edge s d f t g =
    let g = add_vx s (add_vx d g) in
    MapsTo.add s (NodeSet.add (d,f,t) (MapsTo.find s g)) g
  let build_residual g =
    MapsTo.fold (fun src nexts gacc ->
        NodeSet.fold (fun (dst,w,t) g2 ->
            Weighted.add_edge src dst (t-w)
              (Weighted.add_edge dst src w g2))
          nexts gacc)
      g Weighted.empty
  let max_flow src g = let nexts = MapsTo.find src g in
                       NodeSet.fold (fun (d,w,c) acc -> acc+w)
                         nexts 0
  let used_edges g =
    MapsTo.fold
      (fun _ nexts acc ->
        NodeSet.fold (fun (d,w,c) acc2 -> if w > 0 then acc2+1 else acc2)
          nexts acc)
      g 0
  
  let print_residual g = Weighted.print_graph (build_residual g)
  let print_flow g =
    MapsTo.fold
      (fun src nexts () ->
        Printf.printf "%s: [" src;
        NodeSet.iter (fun (dst,w,t) ->
            Printf.printf "%s (%d/%d), " dst w t;) nexts;
        print_string "]\n")
      g ()

  let print_used_edges g =
    MapsTo.fold
      (fun src nexts () ->
        NodeSet.iter (fun (d,m,c) ->
            if m > 0
            then Printf.printf "%s %s %d\n" src d m
            else ()) nexts)
      g ()

  let augment_weight_one src dst w g =
    (* val augment_weight_one: string -> string -> t -> t -> t *)
    MapsTo.mapi (fun s ds ->
        if s = src
        then NodeSet.map (fun (d,m,c) -> if d = dst
                                         then (d,m+w,c)
                                         else (d,m,c))
               ds
        else ds) g
  
  let rec augment_weight path w g = match path with
    (* val augment_weight: string list -> int -> t -> t *)
  (* Return g with every edge in path being assigned a weight += w *)
    |[] -> g
    |[hd] -> g
    |dst::src::tl -> let new_g = augment_weight_one src dst w g in
                     augment_weight (src::tl) w new_g
      
  let rec dinitz src dst g =
    try
      let gf = build_residual g in
      let one_shortest = List.hd (Weighted.shortests src dst gf) in
      let weight_one_shortest = Weighted.min_weight one_shortest gf in
      let gnew = augment_weight one_shortest weight_one_shortest g in
      dinitz src dst gnew
  with Weighted.Inaccessible -> g
  
end
