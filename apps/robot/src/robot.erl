%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 九月 2018 上午9:57
%%%-------------------------------------------------------------------
-module(robot).
-author("feng.liao").

-behaviour(websocket_client_handler).

-export([
    start_link/1,
    init/2,
    websocket_handle/3,
    websocket_info/3,
    websocket_terminate/3
    ]).

start_link(Id) ->
    websocket_client:start_link("ws://127.0.0.1:8080", ?MODULE, [Id]).

init([Id], _ConnState) ->
    {ok, #{id => Id}}.

websocket_handle({text, Msg}, _ConnState, State) ->
    io:format("Received msg ~p~n", [Msg]),
    timer:sleep(1000),
    BinInt = list_to_binary(integer_to_list(State)),
    Reply = {text, <<"hello, this is message #", BinInt/binary >>},
    io:format("Replying: ~p~n", [Reply]),
    {reply, Reply, State};


websocket_handle({binary, Msg}, _ConnState, State) ->
    io:format("Received msg ~p~n", [Msg]),
    {ok, State}.

websocket_info({binary, MsgBin}, _ConnState, State) ->
    {reply, {binary, MsgBin}, State};

websocket_info({binary, heart, MsgBin}, _ConnState, State) ->
    erlang:send_after(25000, self(),{binary, heart, MsgBin}),
    {reply, {binary, MsgBin}, State};

websocket_info(start, _ConnState, State) ->
    {reply, {text, <<"erlang message received">>}, State}.

websocket_terminate(Reason, _ConnState, State) ->
    io:format("Websocket closed in state ~p wih reason ~p~n", [State, Reason]),
    ok.