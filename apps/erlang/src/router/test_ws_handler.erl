%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 二月 2019 下午5:18
%%%-------------------------------------------------------------------

-module(test_ws_handler).

-author("feng.liao").

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, _Opts) ->
    io:format("connet success \n"),
    State = #{},
    {cowboy_websocket, Req, State}.

websocket_init(State) ->
    io:format("State ~p", [State]),
    erlang:start_timer(1000, self(), <<"Hello!">>),
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    {reply, {text, << "That's what she said! ", Msg/binary >>}, State};
websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
    erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, State};
websocket_info(_Info, State) ->
    {ok, State}.
