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
-include("all_pb.hrl").

-author("feng.liao").

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, _Opts) ->
    Ip = http:get_real_ip(Req),
    ?info("~p connet success", [Ip]),
    State = #{ip => Ip},
    {cowboy_websocket, Req, State}.

websocket_init(State) ->
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    ReplyBin = web_test:dispatch(Msg),
    {reply, {text, << ReplyBin/binary >>}, State};

websocket_handle({binary, MsgBin}, State) ->
    {Msg, _} = pt:decode_msg(MsgBin),
    case Msg of
        #'C2S_Heartbeat'{} ->
            ignore;
        _ ->
            ?info("server received: ~p", [Msg])
    end,
    client_hdl:dispatch(Msg, State);

websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({binary, Msg}, State) ->
    {MsgBin, _} = pt:decode_msg(Msg),
    {reply, {binary, MsgBin}, State};

websocket_info(_Info, State) ->
    {ok, State}.
