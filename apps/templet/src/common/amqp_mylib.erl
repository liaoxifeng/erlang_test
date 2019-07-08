%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% 上传到mq
%%% @end
%%% Created : 28. 六月 2018 16:34
%%%-------------------------------------------------------------------
-module(amqp_mylib).
-author("feng.liao").

-include("common.hrl").
-include("for_rabbitmq.hrl").

%% API
-export([
%%    upload_info/2,
%%    publish/2,
%%    async_publish/2,
    reset_conn/0,
    get_conn/0
]).

%%%% 上传游戏数据的财务,业务信息表
%%%% 插入一条数据。先存 mnesia, 再异步上传 RabbitMQ, mq返回成功后删除 mnesia.
%%upload_info(Exchange, Items) ->
%%
%%    Json = jsx:encode(Items),
%%    Value = tool:to_binary(Json),
%%
%%    case publish(Value, Exchange) of
%%        ok ->
%%            ok;
%%
%%        {error, _Reason} ->
%%%%                    ?print("~p", [_Reason]),
%%            Key = util:unixtime_microsecond(),
%%            R = #mn_to_rmq{key = Key, value = Value, exchange = Exchange},
%%            mnesia:dirty_write(R)
%%    end.
%%
%%
%%%% 上传到mq
%%-spec publish(binary(), binary()) -> ok | {error, any()}.
%%publish(Payload, Exchange) ->
%%    case catch poolboy:checkout(rabbitmq_pool) of
%%        C when is_pid(C) ->
%%
%%            Publish = #'basic.publish'{exchange = Exchange},
%%            Content = #amqp_msg{props = #'P_basic' { delivery_mode = 2 }, payload = Payload},
%%            try gen_server:call(C, {publish, Publish, Content}, 10000) of
%%                {ok, ConfirmId} -> %% amqp_srv 已有返回，rabbitmq 的确认可以异步处理
%%                    %% 先释放到 rabbitmq_pool
%%                    poolboy:checkin(rabbitmq_pool, C),
%%
%%                    receive
%%                        {ok_ack, C, ConfirmId} -> %% 有明确返回
%%                            ok;
%%
%%                        Reason ->
%%%%                            ?print("Reason:~p", [Reason]),
%%                            {error, Reason}
%%
%%                    after 1000 ->
%%%%                        ?print("~p timeout", [ConfirmId]),
%%                        {error, {ack, timeout}}
%%                    end;
%%
%%                Reason ->
%%                    {error, Reason}
%%            catch
%%                AClass:AReason ->
%%                    poolboy:checkin(rabbitmq_pool, C),
%%                    {error, {AClass, AReason}}
%%            end;
%%
%%        Reason ->
%%            {error, Reason}
%%    end.
%%
%%
%%%% 异步上传到mq
%%-spec async_publish(binary(), binary()) -> {ok, {pid(), integer()}} | {error, any()}.
%%async_publish(Payload, Exchange) ->
%%    case catch poolboy:checkout(rabbitmq_pool) of
%%        C when is_pid(C) ->
%%
%%            Publish = #'basic.publish'{exchange = Exchange},
%%            Content = #amqp_msg{props = #'P_basic' { delivery_mode = 2 }, payload = Payload},
%%            try gen_server:call(C, {publish, Publish, Content}, 10000) of
%%                {ok, ConfirmId} -> %% amqp_srv 已有返回，rabbitmq 的确认可以异步处理
%%                    %% 先释放到 rabbitmq_pool
%%                    poolboy:checkin(rabbitmq_pool, C),
%%
%%                    {ok, {C, ConfirmId}};
%%
%%                Reason ->
%%                    {error, Reason}
%%            catch
%%                AClass:AReason ->
%%                    poolboy:checkin(rabbitmq_pool, C),
%%                    {error, {AClass, AReason}}
%%            end;
%%
%%        Reason ->
%%            {error, Reason}
%%    end.
%%

%% 新建连接
new_connection(Args) ->
    Username = proplists:get_value(username, Args),
    Password = proplists:get_value(password, Args),
    Host = proplists:get_value(host, Args),
    Port = proplists:get_value(port, Args),
    Params = #amqp_params_network{
        username = Username,
        password = Password,
        host = Host,
        port = Port
    },
    amqp_connection:start(Params).

%% reset the connection to rabbitmq
reset_conn() ->
    {ok, {_AmqpPoolSizeArgs, AmqpPoolWorkerArgs}} = application:get_env(templet, rabbitmq_pool),
    case new_connection(AmqpPoolWorkerArgs) of
        {ok, Conn} ->
            case ets:lookup(?ets_global, rabbitmq_conn) of
                [{_, OldConn}] ->
                    catch amqp_connection:close(OldConn);
                _ ->
                    ignore
            end,
            ets:insert(?ets_global, {rabbitmq_conn, Conn}),
            {ok, Conn};
        {error, _} = Err ->
            Err
    end.

%% get the connection to rabbitmq
get_conn() ->
    case ets:lookup(?ets_global, rabbitmq_conn) of
        [{_, Conn}] ->
            case is_process_alive(Conn) of
                true ->
                    {ok, Conn};
                false ->
                    reset_conn()
            end;
        _ ->
            reset_conn()
    end.