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
-export([start_link/0, publish/0, ppublish/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, #{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    ?PRINT("~p", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% redis
redis_test() ->
    {ok, Host} = application:get_env(redis, host),
    {ok, Port} = application:get_env(redis, port),
    {ok, Db} = application:get_env(redis, db),
    {ok, Password} = application:get_env(redis, password),
    {ok, Topic} = application:get_env(redis, topic),

    {ok, Client} = eredis:start_link(Host, Port, Db, Password),

    {ok, SetResult} = eredis:q(Client, ["SET", Topic, bar]),
    ?PRINT("SetResult ~p", [SetResult]),
    {ok, GetResult} = eredis:q(Client, ["GET", Topic]),
    ?PRINT("GetResult ~p", [GetResult]),
    eredis:q(Client, ["DEL", Topic]),

    ?assertEqual({ok, undefined}, eredis:q(Client, ["GET", Topic])),
    ?assertEqual({ok, <<"OK">>}, eredis:q(Client, ["SET", Topic, bar])),
    ?assertEqual({ok, <<"bar">>}, eredis:q(Client, ["GET", Topic])),
    ?assertMatch({ok, _}, eredis:q(Client, ["LPUSH", "k1", "b"])),
    ?assertMatch({ok, _}, eredis:q(Client, ["LPUSH", "k1", "a"])),
    ?assertMatch({ok, _}, eredis:q(Client, ["LPUSH", "k2", "c"])),
    eredis:stop(Client).

%% 订阅 topic foo
sub_test() ->
    {ok, Sub} = eredis_sub:start_link([{password, "redis"}]),
    Receiver = spawn_link(fun () ->
        eredis_sub:controlling_process(Sub),
        eredis_sub:subscribe(Sub, [<<"foo">>]),
        receiver(Sub)
                          end),
    {Sub, Receiver}.

%% 订阅 topic foo*
psub_test() ->
    {ok, Sub} = eredis_sub:start_link([{password, "redis"}]),
    Receiver = spawn_link(fun () ->
        eredis_sub:controlling_process(Sub),
        eredis_sub:psubscribe(Sub, [<<"foo*">>]),
        receiver(Sub)
                          end),
    {Sub, Receiver}.

%% 上传数据到redis
publish() ->
    {ok, P} = eredis:start_link("127.0.0.1", 6379, 0, "redis"),
    eredis:q(P, ["PUBLISH", "foo", "bar"]),
    eredis_client:stop(P).

ppublish() ->
    {ok, P} = eredis:start_link("127.0.0.1", 6379, 0, "redis"),
    eredis:q(P, ["PUBLISH", "foo4", "bar44"]),
    eredis_client:stop(P).

%% 订阅者结束数据
receiver(Sub) ->
    receive
        Msg ->
            ?PRINT("received ~p", [Msg]),
            eredis_sub:ack_message(Sub),
            receiver(Sub)
    end.


%% 阻塞tcp socket
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


%% mysql
mysql_test() ->
    #{
        host := Host, account := Account,
        password := Password, db := Db,
        topic := Topic} = maps:from_list(application:get_all_env(mysql)),

    {ok, _} = mysql:start_link(Topic, Host, Account, Password, Db),

    {data, MySqlRes}  = mysql:fetch(Topic, <<"select * from test">>),
    ?PRINT("QueryResult ~p", [MySqlRes]),

    %% 获取字段名称信息
    FieldInfo = mysql:get_result_field_info(MySqlRes),
    ?PRINT("FieldInfo ~p", [FieldInfo]),

    %% 获取字段值
    AllRows = mysql:get_result_rows(MySqlRes),
    ?PRINT("AllRows ~p", [AllRows]),

    mysql:fetch(Topic, <<"DELETE FROM test where userid = 'feng'">>),

    mysql:fetch(Topic, <<"INSERT INTO test(token, timeout) VALUES "
    "(6, 3)">>),
    ok.

%%
%%    %% 加密密码
%%    {ok, _} = mysql:start_link(p2, "localhost", "root", "123456", "students_db"),
%%
%%    Name = "'feng1'",
%%    Password1 = "aes_encrypt('password', 'salt')",
%%    mysql:fetch(p2, list_to_binary("INSERT INTO students(name, password) VALUES (" ++ Name ++ "," ++ Password1 ++ ")")).

fs_test() ->
    fs:start_link(fs_watcher),
    fs:subscribe(fs_watcher),
    fs:known_events(fs_watcher).

statem_event_test() ->
    {ok, Pid} = statem_event_test:start_link(),
    ?PRINT("Pid ~p", [Pid]),
    gen_statem:cast(Pid, player_hdl),
    gen_statem:call(Pid, player_hdl, 5000),
    gen_statem:reply({self(), tag}, "hello srv").

statem_state_test() ->
    {ok, Pid} = statem_state_test:start_link(),
    ?PRINT("Pid ~p", [Pid]),
    gen_statem:call(Pid, push),
    gen_statem:call(Pid, get_count),
    gen_statem:call(Pid, push),
    gen_statem:call(Pid, get_count),
    gen_statem:stop(Pid).
