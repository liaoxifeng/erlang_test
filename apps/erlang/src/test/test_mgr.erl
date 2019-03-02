%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 二月 2019 下午8:06
%%%-------------------------------------------------------------------

-module(test_mgr).

-include("common.hrl").
-include_lib("eunit/include/eunit.hrl").

-author("feng.liao").

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    publish/0,
    ppublish/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

redis_test() ->
    {ok, Client} = eredis:start_link("127.0.0.1", 6379, 0, "redis"),
    {ok, SetResult} = eredis:q(Client, ["SET", foo, bar]),
    io:format("SetResult ~p\n", [SetResult]),
    {ok, GetResult} = eredis:q(Client, ["GET", "foo"]),
    io:format("GetResult ~p\n", [GetResult]),
    eredis:q(Client, ["DEL", foo]),
    ?assertEqual({ok, undefined}, eredis:q(Client, ["GET", foo])),
    ?assertEqual({ok, <<"OK">>}, eredis:q(Client, ["SET", foo, bar])),
    ?assertEqual({ok, <<"bar">>}, eredis:q(Client, ["GET", foo])),
    ?assertMatch({ok, _}, eredis:q(Client, ["LPUSH", "k1", "b"])),
    ?assertMatch({ok, _}, eredis:q(Client, ["LPUSH", "k1", "a"])),
    ?assertMatch({ok, _}, eredis:q(Client, ["LPUSH", "k2", "c"])),
    eredis:stop(Client).


mysql_test() ->
    {ok, _} = mysql:start_link(p1, "localhost", "root", "123456", "test"),
    {data, MySqlRes}  = mysql:fetch(p1, <<"select * from test">>),
    io:format("QueryResult ~p", [MySqlRes]),

    %% 获取字段名称信息
    FieldInfo = mysql:get_result_field_info(MySqlRes),

    %% 获取字段值
    AllRows   = mysql:get_result_rows(MySqlRes),

    mysql:fetch(p1, <<"DELETE FROM test where userid = 'feng'">>),

    mysql:fetch(p1, <<"INSERT INTO test(token, timeout) VALUES "
    "(6, 3)">>),



    {ok, _} = mysql:start_link(p2, "localhost", "root", "123456", "students_db"),

    Name = "'feng1'",
    Password = "aes_encrypt('password', 'salt')",
    mysql:fetch(p2, list_to_binary("INSERT INTO students(name, password) VALUES (" ++ Name ++ "," ++ Password ++ ")")).

sub_test() ->
    {ok, Sub} = eredis_sub:start_link([{password, "redis"}]),
    Receiver = spawn_link(fun () ->
        eredis_sub:controlling_process(Sub),
        eredis_sub:subscribe(Sub, [<<"foo">>]),
        receiver(Sub)
                          end),
    {Sub, Receiver}.

psub_test() ->
    {ok, Sub} = eredis_sub:start_link([{password, "redis"}]),
    Receiver = spawn_link(fun () ->
        eredis_sub:controlling_process(Sub),
        eredis_sub:psubscribe(Sub, [<<"foo*">>]),
        receiver(Sub)
                          end),
    {Sub, Receiver}.

publish() ->
    {ok, P} = eredis:start_link("127.0.0.1", 6379, 0, "redis"),
    eredis:q(P, ["PUBLISH", "foo", "bar"]),
    eredis_client:stop(P).

ppublish() ->
    {ok, P} = eredis:start_link("127.0.0.1", 6379, 0, "redis"),
    eredis:q(P, ["PUBLISH", "foo4", "bar44"]),
    eredis_client:stop(P).

receiver(Sub) ->
    receive
        Msg ->
            io:format("received ~p~n", [Msg]),
            eredis_sub:ack_message(Sub),
            receiver(Sub)
    end.

tcp_test() ->
    Args = #{
        id       => ?undefined,
        shutdown => 2000,
        start    => {block_client, start_link, []},
        modules  => [block_client],
        restart  => permanent,
        type     => worker
    },
    ?assertMatch({ok, _}, block_client_sup:start_child(Args)).