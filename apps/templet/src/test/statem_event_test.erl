%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 三月 2019 上午9:51
%%%-------------------------------------------------------------------
-module(statem_event_test).
-author("feng.liao").
-include("common.hrl").
-behaviour(gen_statem).

%% API
-export([start_link/0, player_hdl/1]).

%% gen_statem callbacks
-export([init/1, handle_event/4, terminate/3, code_change/4, callback_mode/0]).

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
    State = #{counts => 4},
    {ok, start, State}.

callback_mode() ->
    ?PRINT("callback mode"),
    handle_event_function.

handle_event(cast, player_hdl, StateName, #{counts := Counts} = State) when StateName /= 'end' ->
    player_hdl(Counts),
    Counts1 = Counts - 1,
    State1 = State#{counts => Counts1},
    case Counts of
        1 ->
            {next_state, 'end', State1};
        _ ->
            {keep_state, State1, [{state_timeout, 10000, player_hdl}]}
    end;

handle_event(cast, player_hdl, 'end', State) ->
    ?PRINT("状态机已结束 State ~p", [State]),
    {keep_state_and_data, []};

handle_event({call, From}, _EventContent, _StateName, #{counts := Counts} = State) ->
    player_hdl(Counts),
    Counts1 = Counts - 1,
    State1 = State#{counts => Counts1},
    case Counts of
        1 ->
            {next_state, 'end', State1, [{reply, From, Counts}]};
        _ ->
            {keep_state, State1, [{reply, From, Counts}, {state_timeout, 10000, player_hdl}]}
    end;

handle_event(state_timeout, player_hdl, _StateName, #{counts := Counts} = State) ->
    player_hdl(Counts),
    Counts1 = Counts - 1,
    State1 = State#{counts => Counts1},
    case Counts1 of
        0 ->
            {next_state, 'end', State1};
        _ ->
            {keep_state, State1, [{state_timeout, 10000, player_hdl}]}
    end;

handle_event(EventType, EventContent, _StateName, _State) ->
    ?WRN("not match ~p ~p", [EventType, EventContent]),
    {keep_state_and_data, []}.

terminate(_Reason, _StateName, _State) ->
    ok.

code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

player_hdl(Num) ->
    ?PRINT("player hdl ~p", [Num]).