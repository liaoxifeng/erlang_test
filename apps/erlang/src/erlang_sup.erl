%%%-------------------------------------------------------------------
%% @doc erlang top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erlang_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_all, 0, 1},
        [
%%            ?CHILD(block_server_sup, supervisor),
%%            ?CHILD(block_client_sup, supervisor),
%%            ?CHILD(statem_test, worker),
            ?CHILD(test_mgr, worker)


        ]} }.

%%====================================================================
%% Internal functions
%%====================================================================
