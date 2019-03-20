%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 三月 2019 下午1:44
%%%-------------------------------------------------------------------

-module(mqtt_srv).
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
    {ok, Client} = emqttc:start_link(Config),
    {ok, Topic} = application:get_env(erlang_test, s2c_topic),
    emqttc:subscribe(Client, Topic, 2),
    {ok, #{topic => Topic, client => Client}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({publish, <<"s2c_foo">>, Binary}, State) ->
    ?INF("receive ~p", [Binary]),
    {noreply, State};

handle_info({mqttc, _Pid, connected}, State) ->
    ?INF("mqtt_srv connected"),
    {noreply, State};

handle_info(Info, State) ->
    ?ERR("~p", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
