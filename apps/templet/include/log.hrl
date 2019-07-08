%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 打印
%%% @end
%%% Created : 02. 三月 2019 下午2:12
%%%-------------------------------------------------------------------
-ifndef(__log_hrl__).
-define(__log_hrl__, true).

-define(debug(Fmt), lager:debug([], Fmt, [])).
-define(debug(Fmt, Args), lager:debug([], Fmt, Args)).

-define(info(Fmt), lager:info([], Fmt, [])).
-define(info(Fmt, Args), lager:info([], Fmt, Args)).

-define(warning(Fmt), lager:warning([], Fmt, [])).
-define(warning(Fmt, Args), lager:warning([], Fmt, Args)).

-define(error(Fmt), lager:error([], Fmt, [])).
-define(error(Fmt, Args), lager:error([], Fmt, Args)).

-define(print(Fmt), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE])).
-define(print(Fmt, Args), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE|Args])).

-endif.