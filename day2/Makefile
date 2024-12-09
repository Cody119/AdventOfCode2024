INPUT=day2.input

.PHONY: default
default: run_2

.PHONY: run_1
run_1: build
	echo 'part_one(X).' | swi-prolog.swipl day2.pl day2.input.pl

.PHONY: example_1
example_1: build
	echo 'part_one(X).' | swi-prolog.swipl day2.pl day2.exp.pl

.PHONY: run_2
run_2: build
	echo 'part_two(X).' | swi-prolog.swipl day2.pl day2.input.pl

.PHONY: example_2
example_2: build
	echo 'part_two(X).' | swi-prolog.swipl day2.pl day2.exp.pl

.PHONY: build
build: day2.exp.pl day2.input.pl

day2.exp.pl: day2.exp
	python3 pre_process.py day2.exp

day2.input.pl: day2.input
	python3 pre_process.py day2.input