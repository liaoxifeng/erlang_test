%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 三月 2019 上午10:02
%%%-------------------------------------------------------------------

-module(mysql_srv).
-author("feng.liao").

-include("common.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0, log/4]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, Config} = application:get_env(erlang_test, mysql),
    #{host := Host, account := Account, password := Password,
        db := Db, topic := Topic} = maps:from_list(Config),

    case mysql:start_link(Topic, Host, 3306, Account, Password, Db, fun log/4) of
        {ok, _} ->
            ?INF("mysql start success");
        _ ->
            ?ERR("mysql start failure")
    end,
    {ok, #{account => Account, password => Password, db => Db, topic => Topic}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
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
