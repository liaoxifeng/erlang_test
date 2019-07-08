%%%-------------------------------------------------------------------
%% @doc templet top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(templet_sup).

-behaviour(supervisor).

-include("common.hrl").

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Args), {I, {I, start_link, [Args]}, permanent, 5000, Type, [I]}).
%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    Ret = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    {ok, _} = supervisor:start_child(?MODULE, {player_sup, {player_sup, start_link,[]},
        transient, infinity, supervisor, [player_sup]}),
    code:ensure_loaded(mqtt_hdl),
    Ret.

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    ets:new(?ets_global, [set, named_table, public, {keypos, 1}, {read_concurrency, true}]),

%%    {ok, {AmqpSizeArgs, _AmqpWorkerArgs}} = application:get_env(templet, rabbitmq_pool),
%%    AmqpPoolArgs = [{name, {local, rabbitmq_pool}}, {worker_module, amqp_publisher}] ++ AmqpSizeArgs,
%%    AmqpPoolSpecs = poolboy:child_spec(rabbitmq_pool, AmqpPoolArgs, []),
%%
%%    {ok, {MysqlSizeArgs, MysqlWorkerArgs}} = application:get_env(templet, mysql_pool),
%%    MysqlPoolArgs = [{name, {local, mysql_pool}}, {worker_module, mysql_srv}] ++ MysqlSizeArgs,
%%    MysqlPoolSpecs = poolboy:child_spec(mysql_pool, MysqlPoolArgs, MysqlWorkerArgs),

%%    {ok, MqttConfig} = application:get_env(templet, emqttc),
    {ok, { {one_for_all, 10, 10},
        [
            ?CHILD(templet_init, worker),
%%            ?CHILD(mqtt_publisher, worker, MqttConfig),
%%            ?CHILD(mqtt_srv, worker, MqttConfig),
%%            ?CHILD(mysql_dispatcher, worker, MqttConfig),
%%            AmqpPoolSpecs,
%%            MysqlPoolSpecs,
            %% for test
            ?CHILD(test_mgr, worker)

        ]} }.

%%====================================================================
%% Internal functions
%%====================================================================
