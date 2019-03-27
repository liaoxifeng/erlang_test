%%%-------------------------------------------------------------------
%% @doc templet top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(templet_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Args), {I, {I, start_link, [Args]}, permanent, 5000, Type, [I]}).
%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    Ret = supervisor:start_link({local, ?SERVER}, ?MODULE, []),
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
    {ok, MqttConfig} = application:get_env(templet, emqttc),
    {ok, { {one_for_all, 10, 10},
        [
            ?CHILD(templet_init, worker),
            ?CHILD(mysql_srv, worker),
            ?CHILD(mqtt_publisher, worker, MqttConfig),
            ?CHILD(db_srv, worker, MqttConfig),
            ?CHILD(mqtt_srv, worker, MqttConfig),
            %% for test
            ?CHILD(test_mgr, worker)

        ]} }.

%%====================================================================
%% Internal functions
%%====================================================================
