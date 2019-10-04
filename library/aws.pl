:- module(aws,
          [ describe/2,
            describe/3,
            filt/2
          ]).

:- use_module(library(http/json), [json_read/2]).
:- use_module(library(lists), [subset/2]).

action(vpc, ['ec2', 'describe-vpcs'], 'Vpcs').
action(instance, ['ec2', 'describe-instances'], 'Reservations').
action(volume, ['ec2', 'describe-volumes'], 'Volumes').

aws(Params, Results) :-
  process_create(path(aws), Params, [stdout(pipe(Pipe))]),
  json_read(Pipe, Results).

aws(Params, Filter, Results) :-
  flatten([Params, ["--filter"], Filter], FullParams),
  process_create(path(aws), FullParams, [stdout(pipe(Pipe))]),
  json_read(Pipe, Results).

% doaction(['ec2', 'describe-volumes'], 'Volumes', X)
doaction(Arguments, Key, Return) :-
  aws(Arguments, Returns),
  Returns = json([Key=ReturnList]),
  member(Return, ReturnList).

% doaction(['ec2', 'describe-volumes'], 'Volumes',  ['Name=availability-zone,Values=us-east-1e', 'Name=size,Values=100'], X)
doaction(Arguments, Key, Prefilter, Return) :-
  aws(Arguments, Prefilter, Returns),
  Returns = json([Key=ReturnList]),
  member(Return, ReturnList).

% describe(volume, X)
describe(Type, Return) :-
  action(Type, Arguments, Key),
  doaction(Arguments, Key, Return).

% describe(volume, ['Name=availability-zone,Values=us-east-1a', 'Name=size,Values=8000'], X)
describe(Type, Prefilter, Return) :-
  action(Type, Arguments, Key),
  doaction(Arguments, Key, Prefilter, Return).

%  describe(volume, ['Name=availability-zone,Values=us-east-1a', 'Name=size,Values=8000'], X), filt('State'='in-use'), X).
filt(Attributes, Resource) :-
  json(Attribs) = Resource,
  (
    subset(Attributes, Attribs);
    subset([Attributes], Attribs)
  ).

% options(options{'availability-zone': 'us-west-2', iops: 100}, X).
options(Input, Output) :-
  dict_pairs(Input, _, Pairs),
  maplist(stringify, Pairs, OutList),
  atomic_list_concat(OutList, ' ', Output),
  !.

stringify(X, Y) :-
  compound_name_arguments(X, _, I),
  swritef(Y, '--%w %w', I).
