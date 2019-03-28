%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 与数据库交互的进程，可以另开一个项目
%%% @end
%%% Created : 28. 三月 2019 上午10:12
%%%-------------------------------------------------------------------

-module(mysql_dispatcher).
-author("feng.liao").

-behaviour(gen_server).
-include("common.hrl").

%% API
-export([start_link/1, log/4]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Args) ->
    mysql:start_link(mysql_pool, "192.168.1.36", 3306, "feng", "liao123456", "feng_db", fun log/4),
    gen_server:start_link(?MODULE, [Args], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Config0]) ->
    Config = lists:keyreplace(client_id, 1, Config0, {client_id, <<"operator">>}),
    {ok, Client} = emqttc:start_link(operator, Config),
    {ok, C2STopic} = application:get_env(templet, c2s_topic),
    emqttc:subscribe(Client, C2STopic, 2),
    {ok, #{client => Client}}.

handle_call(get_logfun, _From, State) ->
    {reply, {ok, fun log/4}, State};

handle_call({add_conn, _Info}, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({publish, <<"c2s_foo">>, Binary}, State) ->
    Binary1 = maps:from_list(jsx:decode(Binary)),
    case poolboy:checkout(mysql_pool) of
        C when is_pid(C) ->
            case gen_server:call(C, {publish, <<"s2c_foo">>, Binary1}, 10000) of
                {ok, _ConfirmId} ->
                    %% 先释放到 rabbitmq_pool
                    poolboy:checkin(mysql_pool, C);
                _ ->
                    ?ERR("update db failture")
            end;
        _E ->
            ?WRN("~p", [_E])
    end,
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

%% 去除不必要的打印信息
%% 增加一个log函数，只容许error级别的打印，其他的都不打了。
log(Module, Line, Level, FormatFun) ->
    case Level of
        error ->
            {Format, Arguments} = FormatFun(),
            io:format("~w:~b: "++ Format ++ "~n", [Module, Line] ++ Arguments);
        _ ->
            ok
    end.
