%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 二月 2019 下午4:05
%%%-------------------------------------------------------------------
-module(statem_test).

-include("common.hrl").
-define(STAGE_NOT_START, 1).     %% 准备/未开始
-define(STAGE_PRE_FLOP, 2).      %% 翻公共牌前
-define(STAGE_FLOP, 3).          %% 翻牌后
-define(STAGE_TURN, 4).          %% 转牌后
-define(STAGE_RIVER, 5).         %% 河牌后
-define(STAGE_SHOWDOWN, 6).      %% 比牌后


-author("feng.liao").

-behaviour(gen_statem).

%% API
-export([start_link/0]).

%% gen_statem callbacks
-export([
    init/1,
    format_status/2,
    state_name/3,
    handle_event/4,
    terminate/3,
    code_change/4,
    callback_mode/0
]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================

init([]) ->
    {ok, ?STAGE_NOT_START, #state{}}.

callback_mode() ->
    handle_event_function.

format_status(_Opt, [_PDict, _StateName, _State]) ->
    Status = some_term,
    Status.

state_name(_E, _R, State) ->
    io:format("hello timeout"),
    NextStateName = next_state,
    {next_state, NextStateName, State}.

handle_event(cast, EventContent, StateName, State) ->
    io:format("EventContent ~p\n", [EventContent]),
    io:format("StateName ~p\n", [StateName]),
    io:format("State ~p\n", [State]),

    {next_state, StateName+1, State, [{state_timeout, 10000, lock}]};

handle_event({call,From}, EventContent, StateName, State) ->
    io:format("EventContent ~p\n", [EventContent]),
    io:format("StateName ~p\n", [StateName]),
    io:format("State ~p\n", [State]),
    {next_state, StateName+1, State};

handle_event(info, EventContent, StateName, State) ->
    io:format("EventContent ~p\n", [EventContent]),
    io:format("StateName ~p\n", [StateName]),
    io:format("State ~p\n", [State]),
    {next_state, StateName+1, State};

handle_event(EventType, EventContent, StateName, State) ->
    io:format("EventType ~p\n", [EventType]),
    io:format("EventContent ~p\n", [EventContent]),
    io:format("StateName ~p\n", [StateName]),
    io:format("State ~p\n", [State]),
    {next_state, StateName+1, State}.

terminate(_Reason, _StateName, _State) ->
    ok.

code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
