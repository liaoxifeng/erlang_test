%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 三月 2019 上午9:39
%%%-------------------------------------------------------------------

-module(db_lib).
-include("proto_bo.hrl").
-include("common.hrl").
-define(db_topic, mysql_pool).

-author("feng.liao").

%% API
-export([
    insert/1,
    delete/0,
    select/1,
    hdl/2]).

hdl(#{<<"cmd">> := ?register_g2b, <<"tag">> := Tag, <<"user_name">> := UserName,
    <<"password">> := Password, <<"phone_number">> := PhoneNumber},
        Topic) ->

    Binary = format_sql("INSERT INTO user_info(user_name,password,money,phone_number) "
    "VALUES ('~s','~s',~p,'~s');", [UserName, Password, 0, PhoneNumber]),
    Code = insert(Binary),
    CmdBinary = jsx:encode([{cmd, ?register_b2g}, {tag, Tag}, Code]),
    mqtt_hdl:publish(Topic, CmdBinary);

hdl(#{<<"cmd">> := ?login_g2b, <<"tag">> := Tag, <<"user_name">> := UserName, <<"password">> := Password},
        Topic) ->
    Binary = format_sql("select * from user_info where user_name = '~s' and password = '~s';",
        [UserName, Password]),
    CmdContent = case select(Binary) of
        [Result] ->
            R1 = maps:to_list(Result),
            [{cmd, ?login_b2g}, {tag, Tag}, {code, 0} | R1];
        _ ->
            [{cmd, ?login_b2g}, {tag, Tag}, {code, 1}]
    end,
    CmdBinary = jsx:encode(CmdContent),
    mqtt_hdl:publish(Topic, CmdBinary);

hdl(#{<<"cmd">> := ?login_g2b}, _Topic) ->
    mqtt_hdl:publish(<<"s2c_foo">>),
    ok.

insert(Binary) ->
    case mysql:fetch(?db_topic, Binary) of
        {updated, _} ->
            {code, 0};
        _ ->
            {code, 1}
    end.

delete() ->
    mysql:fetch(?db_topic, <<"DELETE FROM test where userid = 'feng'">>).

select(Binary) ->
    case mysql:fetch(?db_topic, Binary) of
        {data, {mysql_result, Struct, Results,_, _, _,_,_}} ->
            StructT = list_to_tuple([I || {_, I, _, _} <- Struct]),
            lists:map(
                fun(Result) ->
                    Lens = lists:seq(1, length(Result)),
                    ResultT = list_to_tuple(Result),
                    maps:from_list([{element(I, StructT), element(I, ResultT)} || I <- Lens])
                end, Results);
        E ->
            ?error("~p", [E]),
            E
    end.

format_sql(Format, Args) ->
    lists:flatten(io_lib:format(Format, Args)).