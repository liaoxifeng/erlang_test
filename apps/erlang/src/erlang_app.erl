%%%-------------------------------------------------------------------
%% @doc erlang public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_app).
-include("common.hrl").
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", test_ws_handler, []},

            %% for test
            {"/home", cowboy_static, {priv_file, erlang, "index.html"}},
            {"/static/[...]", cowboy_static, {priv_dir, erlang, "static"}}
        ]}
    ]),
    {ok, Port} = application:get_env(erlang_test, port),
    ?INF("cowboy listen [~p]",[Port]),
    {ok, _} = cowboy:start_clear(http, [{port, Port}], #{
        env => #{dispatch => Dispatch}
    }),
    erlang_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
