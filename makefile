.PHONY: clean

all: one two

one: graph.cmo analyse.cmo main.cmo
	ocamlc graph.cmo analyse.cmo main.cmo -o main

two: graph2.cmo analyse.cmo main2.cmo
	ocamlc graph2.cmo analyse.cmo main2.cmo -o main2

test: all
	./main

%.cmi: %.mli
	ocamlc -c $< -o $@

%.cmo: %.ml
	ocamlc -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main

graph.cmo: graph.cmi
graph2.cmo: graph2.cmi
analyse.cmo: analyse.cmi
