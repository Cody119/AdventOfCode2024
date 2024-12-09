load_data(X) :- findall(Y, data(Y), X).

all_variations([], _, []).
all_variations([H|T], N, Z) :- append(N, T, M), append(N, [H], O), all_variations(T, O, W), Z=[M|W].

increasing([_|[]]).
increasing([X,Y|T]) :- X < Y, increasing([Y|T]).

decreasing([_|[]]).
decreasing([X,Y|T]) :- X > Y, decreasing([Y|T]).

max_diff([_|[]], _).
max_diff([X,Y|T], M) :- D is abs(Y - X), D =< M, max_diff([Y|T], M).

valid(X) :- max_diff(X, 3), (increasing(X); decreasing(X)).

valid_two(X) :- valid(X); (all_variations(X, [], Y), member(Z, Y), valid(Z)).

valid_count([], 0).
valid_count([H|T], N) :- valid(H) -> valid_count(T, M), N is M + 1; valid_count(T, N).

valid_count_two([], 0).
valid_count_two([H|T], N) :- valid_two(H) -> valid_count_two(T, M), N is M + 1; valid_count_two(T, N).

part_one(X) :- load_data(D), valid_count(D, X).

part_two(X) :- load_data(D), valid_count_two(D, X).