%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 三月 2019 下午1:45
%%%-------------------------------------------------------------------

-module(mqtt_publisher).
-author("feng.liao").
-include("common.hrl").
-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Args], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Config]) ->
    {ok, Client} = emqttc:start_link(emqtt_publisher, Config),
    {ok, #{client => Client}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({publish, Topic, CmdBinary}, #{client := Client} = State) ->
    emqttc:publish(Client, Topic, CmdBinary),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================