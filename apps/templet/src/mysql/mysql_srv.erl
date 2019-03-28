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
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Args) ->
    gen_server:start_link(?MODULE, [Args], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Args]) ->
    Hostname = proplists:get_value(hostname, Args),
    Database = proplists:get_value(database, Args),
    Username = proplists:get_value(username, Args),
    Password = proplists:get_value(password, Args ),
    mysql:connect(mysql_pool, Hostname, undefined, Username, Password, Database, true),
    ?INF("add into mysql_pool"),
    {ok, #{user_name => Username, password => Password, db => Database}}.

handle_call({publish, Publish, Binary}, _From, State) ->
    Reply = db_lib:hdl(Binary, Publish),
    {reply, {ok, Reply}, State};

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