open Graph2

(* Phase 2 *)

(* Parsing du fichier *)
let leBarC, jf, coul_list = Analyse.phase2 ()

(* Construction du graphe *)
let construct_graph clist =
  let rec constr_aux g clist = match clist with
    |[] -> g
    |(s,d,w)::tl -> constr_aux (FlowGraph.add_edge s d 0 w g) tl
  in constr_aux FlowGraph.empty clist


let gbase = construct_graph coul_list;;

let gr = FlowGraph.dinitz leBarC jf gbase;;

(*FlowGraph.print_flow gr;;
FlowGraph.print_residual gr;;*)

Printf.printf "%d\n" (FlowGraph.max_flow leBarC gr);;
Printf.printf "%d\n" (FlowGraph.used_edges gr);;
FlowGraph.print_used_edges gr;;
