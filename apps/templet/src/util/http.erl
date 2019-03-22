%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2019 下午8:13
%%%-------------------------------------------------------------------

-module(http).

-author("feng.liao").

%% API
-export([get_real_ip/1]).

%% 取nginx 前的源地址
get_real_ip(#{headers := #{<<"x-forwarded-for">> := Bin}}) ->
    [H|_] = string:tokens(binary_to_list(Bin), ","),
    {ok, Ip} = inet:parse_address(H),
    list_to_binary(inet:ntoa(Ip));

get_real_ip(Req) ->
    {Ip, _} = cowboy_req:peer(Req),
    list_to_binary(inet:ntoa(Ip)).