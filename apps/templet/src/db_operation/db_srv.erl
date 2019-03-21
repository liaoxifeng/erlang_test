%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 与数据库交互的进程，可以另开一个项目
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
    Config = lists:keyreplace(client_id, 1, Config0, {client_id, <<"operator">>}),
    {ok, Client} = emqttc:start_link(operator, Config),
    {ok, C2STopic} = application:get_env(templet, c2s_topic),
    emqttc:subscribe(Client, C2STopic, 2),
    {ok, #{client => Client}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({publish, <<"c2s_foo">>, Binary}, State) ->

    Binary1 = maps:from_list(jsx:decode(Binary)),
    db_lib:db_hdl(Binary1, <<"s2c_foo">>),

    {noreply, State};

handle_info({mqttc, _Pid, connected}, State) ->
    ?INF("mqtt operator connected"),
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
