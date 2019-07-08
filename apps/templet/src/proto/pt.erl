%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 十二月 2018 上午10:47
%%%-------------------------------------------------------------------

-module(pt).

-include("all_pb.hrl").
-include("common.hrl").

-author("feng.liao").

%% API
-export([
    encode_msg/1, encode_msg/2, decode_msg/1,
    encode_err/1, encode_err/2
]).

%% 打包协议
encode_msg(Msg) -> encode_msg(Msg, []).

encode_msg(Msg, Opts) ->
    Body = all_pb:encode_msg(Msg, Opts),
    BodyLen = byte_size(Body),
    Name = atom_to_binary(element(1, Msg), latin1),
    NameLen = byte_size(Name),
    <<NameLen:8, Name/binary, BodyLen:16, Body/binary>>.

%% 解包协议
decode_msg(<<NameLen:8, NameBin:NameLen/binary, BodyLen:16, Body:BodyLen/binary, LeftBin/binary>>) ->
    MsgName = binary_to_atom(NameBin, latin1),
    {all_pb:decode_msg(Body, MsgName), LeftBin}.

%% 打包错误码协议
-spec encode_err(
    all_pb:'EnumS2CErrCode'()) ->
    binary().
encode_err(Code) ->
    Msg = cfg_s2c_err:get_msg(Code),
    encode_err(Code, Msg).

-spec encode_err(
    all_pb:'EnumS2CErrCode'(),
    iolist()) ->
    binary().
encode_err(Code, Msg) ->
    PackMsg = #'S2C_Err'{
        code = Code,
        msg = Msg
    },
    encode_msg(PackMsg).