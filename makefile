.PHONY: all clean

<<<<<<< HEAD
all: graph.cmo analyse.cmo main.cmo
	ocamlc graph.cmo analyse.cmo main.cmo -o main
=======
all: graph.cmo main.cmo
	ocamlc main.cmo -o main
>>>>>>> c2baf921e8a4451c22419725097f1fc63a7ab573

test: all
	./main

%.cmi: %.mli
	ocamlc -c $< -o $@

%.cmo: %.ml
	ocamlc -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main

graph.cmo: graph.cmi
<<<<<<< HEAD
analyse.cmo: analyse.cmi
=======
>>>>>>> c2baf921e8a4451c22419725097f1fc63a7ab573
