%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 三月 2019 下午2:50
%%%-------------------------------------------------------------------

-module(mn).

-author("feng.liao").

-record(person, {name, age, sex}).

-compile([export_all, nowarn_export_all]).

test() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(person, [{attributes, record_info(fields, person)}, {record_name, person}, {disc_copies, [node()]}]),
    mnesia:wait_for_tables([person], infinity),
    ok.
do_upgrade() ->
    Fun = fun(X) ->
        case X of
            {person, Name, Age, Sex, Money} ->
                {person, Name, Age, Sex, Money, 1};
            _ ->
                X
        end
          end,
    mnesia:delete({person, feng}),
    mnesia:dirty_write({person, feng}),
    mnesia:dirty_read({person, feng}),
    NewAttr = [name, age, sex, money,id],
    mnesia:transform_table(person, Fun, NewAttr, person).
