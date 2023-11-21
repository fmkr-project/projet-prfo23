open Graph;;

(* CLI args parsing *)
if (Array.length Sys.argv) != 2
then begin Printf.printf "usage: %s input_file\n" Sys.argv.(0);
           exit(1) end
else ();;

(* Globals *)
let file_path = Sys.argv.(1);;
let script_file = open_in file_path;;

(* Get the endpoints' names *)
let leBarC = input_line script_file;;
let jF = input_line script_file;;
Printf.printf "Recherche de chemins de %s à %s...\n" leBarC jF;;

(* Parse the vertices *)
let edge_amount = int_of_string (input_line script_file);;
let root =
  let rec parse_vertices g acc = match input_line script_file with
  |"" -> failwith "Nombre d'arêtes fourni incorrect"
  |line -> let vertices = String.split_on_char ' ' line in
           if acc > 1
           then
             parse_vertices (StrGraph.add_edge (List.nth vertices 0)
                               (List.nth 1 vertices) g) (acc-1)
           else g
    in parse_vertices StrGraph.empty edge_amount;;
