%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 打印
%%% @end
%%% Created : 02. 三月 2019 下午2:12
%%%-------------------------------------------------------------------
-author("feng.liao").

-define(PRINT(Fmt), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE])).
-define(PRINT(Fmt, Args), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE|Args])).
