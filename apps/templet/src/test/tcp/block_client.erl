%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 三月 2019 下午2:11
%%%-------------------------------------------------------------------

-module(block_client).
-author("feng.liao").

-include("common.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0, start/0]).

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

start() ->
    {ok, Socket} = gen_tcp:connect("192.168.1.36", 2345, [binary, {packet, 0}]),
    ?PRINT("Socket ~p", [Socket]),

    %% 新建一个进程负责接收消息
    Pid = spawn(fun() -> loop() end),
    %% 监听指定进程
    gen_tcp:controlling_process(Socket, Pid),
    gen_tcp:send(Socket, <<"123">>).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    start(),
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, _State) ->
    ?PRINT("~p", [Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

loop() ->
    receive
        {tcp, Socket, Bin}->
            gen_tcp:close(Socket),
            ?PRINT("Client ...~p~n",[Bin]);
        {tcp_closed, _Socket} ->
            ?PRINT("client is close")
    end.


