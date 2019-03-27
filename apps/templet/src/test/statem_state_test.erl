%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 三月 2019 上午9:51
%%%-------------------------------------------------------------------
-module(statem_state_test).
-author("feng.liao").
-include("common.hrl").
-behaviour(gen_statem).

%% API
-export([start_link/0, off/3, on/3]).

%% gen_statem callbacks
-export([init/1, terminate/3, code_change/4, callback_mode/0]).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_statem:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================
%%

init([]) ->
    {ok, off, 0}.

callback_mode() ->
    ?PRINT("callback mode"),
    state_functions.

terminate(Reason, _StateName, State) ->
    ?PRINT("Reason ~p, State ~p", [Reason, State]),
    ok.

code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

off({call, From}, push, Data) ->
    ?PRINT("~p", [Data]),
    {next_state, on, Data + 1, [{reply, From, on}]};

off(EventType, EventContent, Data) ->
    ?PRINT("~p", [Data]),
    handle_event(EventType, EventContent, Data).

on({call, From}, push, Data) ->
    ?PRINT("~p", [Data]),
    {next_state, off, Data,[{reply, From, off}]};

on(EventType, EventContent, Data) ->
    ?PRINT("~p", [Data]),
    handle_event(EventType, EventContent, Data).

handle_event({call, From}, get_count, Data) ->
    ?PRINT("~p", [Data]),
    {keep_state, Data, [{reply, From, Data}]};

handle_event(_, _, Data) ->
    ?PRINT("~p", [Data]),
    {keep_state, Data}.
