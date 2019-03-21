%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 三月 2019 上午10:10
%%%-------------------------------------------------------------------

-module(client_hdl).

-include("common.hrl").
-include("pt_common.hrl").

-author("feng.liao").

%% API
-export([dispatch/2]).

%% 心跳
dispatch(#'C2S_Heartbeat'{}, State) ->
    ReplyBin = pt:encode_msg(pt_common, #'S2C_Heartbeat'{}),
    {reply, {binary, ReplyBin}, State};

%% 注册
dispatch(#'C2S_Register'{} = Msg, State) ->
    ReplyBin = player_hdl:register(Msg),
    {reply, {binary, ReplyBin}, State};

%% 登录
dispatch(#'C2S_Login'{} = Msg, State) ->
    ReplyBin =
        case player_hdl:login(Msg) of
            {UserId, UserName, Money} ->
                case supervisor:start_child(player_sup, [{UserId, UserName, Money, self()}]) of
                    {ok, Pid} when is_pid(Pid) ->
                        pt:encode_msg(pt_common, #'S2C_Login'{use_name = UserName, money = Money});
                    _ ->
                        pt:encode_err('E_S2CErrCode_Sys')
                end;
            _ ->
                pt:encode_err('E_S2CErrCode_LoginCheckTimeout')

        end,
    {reply, {binary, ReplyBin}, State};

dispatch(Unknown, State) ->
    ?WRN("Unknown=~p", [Unknown]),
    {ok, State}.
