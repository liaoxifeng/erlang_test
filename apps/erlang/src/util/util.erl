%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 三月 2019 下午3:24
%%%-------------------------------------------------------------------

-module(util).

-author("feng.liao").

%% API
-export([unixtime/0, to_binary/1]).

unixtime() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.

%% @doc convert any type to binary
-spec to_binary(any()) -> binary().
to_binary(Value) when is_binary(Value) ->
    Value;
to_binary(Value) when is_list(Value) ->
    list_to_binary(Value);
%%atom_to_binary(Msg, utf8);
to_binary(Value) when is_atom(Value) ->
    list_to_binary(atom_to_list(Value));
to_binary(Value) when is_integer(Value) ->
    integer_to_binary(Value);
to_binary(Value) when is_float(Value) ->
    float_to_binary(Value);
to_binary(Value) when is_reference(Value) ->
    list_to_binary(ref_to_list(Value));
to_binary(Value) when is_pid(Value) ->
    list_to_binary(pid_to_list(Value));
to_binary(Value) when is_port(Value) ->
    list_to_binary(port_to_list(Value)).