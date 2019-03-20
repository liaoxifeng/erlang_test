%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 二月 2019 下午5:18
%%%-------------------------------------------------------------------

-module(test_ws_handler).

-include("common.hrl").
-include("pt_common.hrl").

-author("feng.liao").

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, _Opts) ->
    Ip = http:get_real_ip(Req),
    ?INF("connet success ~p", [Ip]),
    State = #{ip => Ip},
    {cowboy_websocket, Req, State}.

websocket_init(State) ->
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    {reply, {text, << "That's what she said! ", Msg/binary >>}, State};

websocket_handle({binary, MsgBin}, State) ->
    MsgBin1 =
        case pt:decode_msg(MsgBin) of
            {#'C2S_Heartbeat'{}, _} ->
                ignore;

            {Msg, _} ->
                ?INF("server received: ~p", [Msg]),
                client_hdl:dispatch(Msg, State);
            _ ->
                <<>>
        end,
    {reply, {binary, MsgBin1}, State};

websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
    erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, State};

websocket_info({binary, Msg}, State) ->
    {MsgBin, _} = pt:decode_msg(Msg),
    {reply, {binary, MsgBin}, State};

websocket_info(_Info, State) ->
    {ok, State}.
