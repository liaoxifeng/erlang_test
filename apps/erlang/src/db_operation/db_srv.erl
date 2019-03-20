%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 三月 2019 下午2:01
%%%-------------------------------------------------------------------

-module(db_srv).
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

init([Config0]) ->
    Config = lists:keyreplace(client_id, 1, Config0, {client_id, <<"db_operator">>}),
    {ok, Client} = emqttc:start_link(db_operator, Config),
    {ok, C2STopic} = application:get_env(erlang_test, c2s_topic),
    emqttc:subscribe(Client, C2STopic, 2),
    {ok, #{client => Client}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({publish, <<"c2s_foo">>, Binary}, State) ->
    mqtt_hdl:publish(<<"s2c_foo">>, Binary),
    {noreply, State};

handle_info(Info, State) ->
    ?INF("~p", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
