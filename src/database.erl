-module(database).
-include_lib("stdlib/include/qlc.hrl").

-export([init_db/1, info_db/1]).

-record(person, {name, age}).

init_db(Nodes) ->
    mnesia:create_schema(Nodes),
    application:ensure_all_started(mnesia),
    [rpc:call(Node, mnesia, start, []) || Node <- Nodes],

    mnesia:create_table(person, [
        {attributes, record_info(fields, person)},
        {type, set},
        {frag_properties, [
            {n_fragments, 6},
%%            {n_disc_copies, 1},
            {node_pool, Nodes}
        ]}
    ]),
    Write = fun(Items) -> [mnesia:write(Item) || Item <- Items], ok end,
    Persons = [
%%        #person{name="Ivan", age=777},
        #person{name="Elisa", age=555}
    ],
    mnesia:activity(sync_dirty, Write, [Persons], mnesia_frag),
    Res = mnesia:activity(sync_dirty, fun(Item) -> mnesia:table_info(person, Item) end, [all], mnesia_frag),

    io:fwrite("************* Res: ***************~n"),
    [io:fwrite("{~p, ~p}~n", [Key, Value]) || {Key, Value} <- Res],
    ok.

info_db(Info) ->
    F = fun(Item) ->
            mnesia:table_info(person, Item)
        end,
    Res = mnesia:activity(sync_dirty, F, [Info], mnesia_frag),
    Res.
%%
%%store_db(NodeName, {Size, Color}) ->
%%    AF = fun() ->
%%        mnesia:write(#ball{size=Size,
%%                           color=Color})
%%    end,
%%    mnesia:transaction(AF).
%%
%%
%%get_db(NodeName) ->
%%    AF = fun() ->
%%        Query = qlc:q([X || X <- mnesia:table(ball),
%%            X#ball.node_name =:= NodeName]),
%%        Results = qlc:e(Query),
%%        lists:map(fun(Item) -> {Item#ball.size, Item#ball.color} end, Results)
%%    end,
%%    {atomic, Balls} = mnesia:transaction(AF),
%%    Balls.
%%
%%
%%delete_db(NodeName) ->
%%    AF = fun() ->
%%        Query = qlc:q([X || X <- mnesia:table(ball),
%%            X#ball.node_name =:= NodeName]),
%%        Results = qlc:e(Query),
%%
%%        F = fun() ->
%%                lists:foreach(fun(Result) -> mnesia:delete_object(Result)
%%            end, Results)
%%        end,
%%        mnesia:transaction(F)
%%    end,
%%    mnesia:transaction(AF).