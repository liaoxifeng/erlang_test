%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 三月 2019 下午2:11
%%%-------------------------------------------------------------------

-module(block_server).
-author("feng.liao").

-include("common.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    start_parallel_server(),
    {ok, #state{}}.

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


start_parallel_server() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}]),
    spawn(fun() -> per_connect(Listen) end).

%每次绑定一个当前Socket后再分裂一个新的服务端进程，再接收新的请求
per_connect(Listen) ->
    ?PRINT("Listen ~p", [Listen]),
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun() -> per_connect(Listen) end),
    ?PRINT("Socket ~p", [Socket]),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            ?PRINT("Server ~p", [Bin]),
            gen_tcp:send(Socket, <<"321">>),
%%            gen_tcp:close(Socket),
            loop(Socket);
        {tcp_closed, Socket} ->

            ?PRINT("Socket is close")
    end.
