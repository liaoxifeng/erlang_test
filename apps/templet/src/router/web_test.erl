%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% 给 websocket 的测试接口
%%% @end
%%% Created : 19. 五月 2018 11:01
%%%-------------------------------------------------------------------
-module(web_test).
-author("feng.liao").

-include("common.hrl").

-compile([export_all, nowarn_export_all]).

%% 分发
dispatch(<<"web ", ArgsBin/binary>>) ->
    [TypeStr, TimesStr | _OtherArgsStr] = get_args(ArgsBin),
    Type = list_to_integer(TypeStr),
    Times = list_to_integer(TimesStr),
    {_, _} = erlang:statistics(wall_clock),
    {_, SinceLastCall} = erlang:statistics(wall_clock),
    Content = io_lib:format("
    type: ~p<br>
    times:  ~p<br>
    use time:~p<br>", [Type, Times, SinceLastCall]),
    iolist_to_binary(Content);

dispatch(_) ->
    <<"unkonwn cmd"/utf8>>.

%% 获取参数
get_args(ArgsBin) ->
    Tokens = string:tokens(binary_to_list(ArgsBin), [$ , $\t]),
    Tokens.

get_opts([ArgNameStr, ArgStr| Tokens], Res) ->
    ArgName = list_to_atom(ArgNameStr),
    get_opts(Tokens, Res#{ArgName => ArgStr});
get_opts([], Res) ->
    Res.

%% 统计相加
stat_plus(A, B) ->
    list_to_tuple([element(1, A)] ++ [plus(element(I, A), element(I, B)) || I <- lists:seq(2, tuple_size(A))]).

plus(A, B) when is_number(A) -> A + B;
%%plus([HA| LA], [HB| LB]) -> [HA+HB | plus(LA, LB)];
plus(A, B) when is_list(A) -> A ++ B;

plus([], []) -> [];
plus(A, B) when is_tuple(A) ->
    list_to_tuple([element(I, A) + element(I, B) || I <- lists:seq(1, tuple_size(A))]).

%% 取机器cpu核数
get_cpu_core_count() ->
    try erlang:system_info(logical_processors)
    catch _:_ -> 1
    end.



