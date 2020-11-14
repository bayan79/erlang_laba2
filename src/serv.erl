-module(serv).

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    database:init_db(),
    io:format("hello~n"),
    {ok, #state{}}.

handle_call({store, {Size, red}}, _From, State) ->
    database:store_db(1, {Size, "red"}),
    {reply, ok};
handle_call({store, {Size, _}}, _From, State) ->
    database:store_db(2, {Size, "not red"}),
    {reply, ok};
handle_call({get, NodeName}, _From, State) ->
    Results = database:get_db(NodeName),
    {reply, Results}.



handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.