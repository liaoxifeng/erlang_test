%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 监控 client
%%% @end
%%% Created : 02. 三月 2019 下午2:09
%%%-------------------------------------------------------------------
-module(block_client_sup).
-author("feng.liao").

-behaviour(supervisor).

%% API
-export([start_link/0,
    start_child/1,
    get_count/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init([]) ->
    {ok, {{one_for_one, 2, 10}, []}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% 返回进程数
get_count() ->
    L = supervisor:count_children(?MODULE),
    {workers, Count} = lists:keyfind(workers, 1, L),
    Count.

start_child(Spec) ->
    supervisor:start_child(?MODULE, Spec).