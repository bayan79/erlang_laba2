-module(serv).

-behaviour(gen_server).

-export([start_link/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-record(state, {}).

start_link(Hosts) ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [Hosts], []).

init([Hosts]) ->
    process_flag(trap_exit, false),
    io:fwrite("==========TEST!!!: ~p~n", [Hosts]),
    [net_adm:ping(Node) || Node <- Hosts],
    database:init_db([node() | nodes()]),
    {ok, #state{}}.


handle_call({store, {Name, Age}}, _From, _) ->
    database:store_db(Name, Age),
    {reply, ok};
handle_call({get, Name}, _, _) ->
    Results = database:get_db(Name),
    {reply, Results};
handle_call({info, Info}, _, _) ->
    Res = database:info_db(Info),
    {reply, Res}.


handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.