-module(database).
-include_lib("stdlib/include/qlc.hrl").

-export([init_db/1, info_db/1, get_db/1, store_db/2]).

-record(person, {name, age}).

init_db(Nodes) ->
    mnesia:create_schema(Nodes),
    [rpc:call(Node, mnesia, start, []) || Node <- Nodes],
    try
        mnesia:create_table(person, [
            {attributes, record_info(fields, person)},
            {type, bag},
            {frag_properties, [
                {n_fragments, 6},
                {node_pool, Nodes}
            ]}
        ])
    after
        body
    end,
    ok.

info_db(Info) ->
    F = fun(Item) -> mnesia:table_info(person, Item) end,
    mnesia:activity(sync_dirty, F, [Info], mnesia_frag).

store_db(Name, Age) ->
    AF = fun() -> mnesia:write(#person{name=Name, age=Age}) end,
    mnesia:activity(sync_dirty, AF, [], mnesia_frag),
    ok.

unwrap_person(Person) ->
    {Person#person.name, Person#person.age}.

get_db(Name) ->
    AF = fun() ->
            Query = qlc:q([X || X <- mnesia:table(person), X#person.name =:= Name]),
            Results = qlc:e(Query),
            lists:map(fun unwrap_person/1, Results)
         end,
    mnesia:activity(sync_dirty, AF, [], mnesia_frag).