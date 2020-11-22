-module(client).

-author("bayan79").

-export([init_app/1, db_info/1, add_person/2, get_person/1]).


init_app(Hosts) ->
    serv:start_link(Hosts).

db_info(Info) ->
    {reply, Response} = serv:handle_call({info, Info}, self(), null),
    io:fwrite("Info[~p]: ~p~n", [Info, Response]).

add_person(Name, Age) ->
    serv:handle_call({store, {Name, Age}}, self(), null),
    io:fwrite("Person added!~n").

get_person(Name) ->
    {reply, Response} = serv:handle_call({get, Name}, self(), null),
    PrintF = fun({Name, Age}) -> io:fwrite("Person: ~p (~p) ~n", [Name, Age]) end,
    lists:map(PrintF, Response),
    ok.
