:- module(awsclpfd,
          [ instance_set/2
          ]).

:- use_module(library(clpfd)).

% instance(class, memory, CPU, storage, network, on-demand, reserved)
instance('m5a.2xlarge', 32, 8, 0, 10, 0.344, 0.219).
instance('t2.micro', 1, 1, 0, 0, 0.0116, 0.0072).
instance_cost(Inst, Cost) :- instance(Inst, _,_,_,_,Cost, _).

get_memory(Inst, Memory) :- instance(Inst, Memory, _,_,_,_,_).

list_sum(List, Sum) :-
  List = [],
  Sum is 0.

list_sum(List, Sum) :-
  [H|T] = List,
  list_sum(T, S),
  Sum is H + S.

base_instance_set(Memory, X) :-
  AtleastMemory #= Memory, %% CHANGE THIS BACK
  instance(Y, AtleastMemory, _, _, _, _, _),
  X = [Y].

instance_set(Memory, X) :- base_instance_set(Memory, X).

% instance_set(10, X), M < 35
% instance_set(Memory, X) :-
%   Memory #=< SingleMemory + SubsetMemory,
%   SingleMemory #< Memory, SingleMemory #> 0,
%   SubsetMemory #< Memory, SubsetMemory #> 0,
%   instance(SingleInstance, SingleMemory, _, _, _, _, _),
%   instance_set(SubsetMemory, Z),
%   Z = [SingleInstance|_],
%   maplist(get_memory, Z, Memories),
%   list_sum(Memories, SubsetMemorySum),
%   SubsetMemorySum #< Memory,
%   append([SingleInstance], Z, X).

instance_set(Memory, Set) :-
  Memory #=< M1 + M2, M1 #< Memory, M2 #< Memory, M1 #> 0, M2 #> 0,
  instance(M1_I, M1, _, _, _, _, _),
  instance_set(M2, M2_Is),
  M2_Is = [M1_I|_],
  label([M1, M2]),
  maplist(get_memory, M2_Is, Memories),
  list_sum(Memories, SubsetMemorySum),
  % print(SubsetMemorySum), print("       "), print(M2), nl,
  SubsetMemorySum #< Memory,
  append([M1_I], M2_Is, Set).
