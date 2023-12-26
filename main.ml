open Graph

(* Phase 1 *)

(* Parsing du fichier *)
let leBarC, jf, coul_list = Analyse.phase1 ()

(* Construction du graphe *)
let construct_graph clist =
  let rec constr_aux g clist = match clist with
    |[] -> g
    |(s,d)::tl -> constr_aux (StrGraph.add_edge s d g) tl
  in constr_aux StrGraph.empty clist


let gr = construct_graph coul_list;;

StrGraph.print_paths (StrGraph.shortests leBarC jf gr);;
