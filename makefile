.PHONY: all clean

all: graph.cmo analyse.cmo main.cmo
	ocamlc graph.cmo analyse.cmo main.cmo -o main

test: all
	./main

%.cmi: %.mli
	ocamlc -c $< -o $@

%.cmo: %.ml
	ocamlc -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main

graph.cmo: graph.cmi
analyse.cmo: analyse.cmi
