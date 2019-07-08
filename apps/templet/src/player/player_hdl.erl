%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 玩家进程处理逻辑
%%% @end
%%% Created : 06. 三月 2019 下午3:46
%%%-------------------------------------------------------------------

-module(player_hdl).

-include("common.hrl").
-include("player.hrl").
-include("pt_common.hrl").
-include("proto_bo.hrl").

-author("feng.liao").

%% API
-export([
    on_terminate/2,
    on_ws_terminate/2,
    register/1,
    login/1]).


on_terminate(_Reason, _State) ->
    ok.

on_ws_terminate(State, _Pid) ->
    {noreply, State}.

register(#'C2S_Register'{use_name = UserName, password = Password, phone_number = PhoneNumber}) ->
    CmdContent = [{cmd, ?register_g2b},
        {user_name, UserName},
        {password, Password},
        {phone_number, PhoneNumber}
    ],
    case mqtt_hdl:call(CmdContent) of
        {ok, #{<<"code">> := 0}} ->
            pt:encode_msg(pt_common, #'S2C_Register'{code = 0});
        _ ->
            pt:encode_msg(pt_common, #'S2C_Register'{code = 1})
    end.

login(#'C2S_Login'{use_name = UserName, password = Password}) ->
    CmdContent = [{cmd, ?login_g2b}, {user_name, UserName}, {password, Password}],
    case mqtt_hdl:call(CmdContent) of
        {ok, #{<<"code">> := 0, <<"user_id">> := UserId, <<"money">> := Money}} ->
            {UserId, UserName, Money};
        _E ->
            ?warning("login request timeout"),
            _E
    end.

