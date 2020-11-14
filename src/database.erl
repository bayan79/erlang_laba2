-module(database).

-include_lib("stdlib/include/qlc.hrl").

-export([init_db/0, store_db/2, get_db/1, delete_db/1]).

-record(ball, {size, color}).

init_db() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    try
        mnesia:table_info(type, ball)
    catch
        exit: _ ->
            mnesia:create_table(ball, [
                {attributes, record_info(fields, ball)},
                {type, bag},
                {disc_copies, [node()]}
            ])
    after
        body
    end.

store_db(NodeName, {Size, Color}) ->
    AF = fun() ->
        mnesia:write(#ball{size=Size,
                           color=Color})
    end,
    mnesia:transaction(AF).

get_db(NodeName) ->
    AF = fun() ->
        Query = qlc:q([X || X <- mnesia:table(ball), 
            X#ball.node_name =:= NodeName]),
        Results = qlc:e(Query),
        lists:map(fun(Item) -> {Item#ball.size, Item#ball.color} end, Results)
    end,
    {atomic, Balls} = mnesia:transaction(AF),
    Balls.

delete_db(NodeName) ->
    AF = fun() ->
        Query = qlc:q([X || X <- mnesia:table(ball),
            X#ball.node_name =:= NodeName]),
        Results = qlc:e(Query),
        
        F = fun() ->
                lists:foreach(fun(Result) -> mnesia:delete_object(Result) 
            end, Results)
        end,
        mnesia:transaction(F)
    end,
    mnesia:transaction(AF).