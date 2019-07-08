%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% RabbitMQ publisher
%%% @end
%%% Created : 04. 七月 2018 16:07
%%%-------------------------------------------------------------------
-module(amqp_publisher).
-author("feng.liao").

-behaviour(gen_server).

-include("for_rabbitmq.hrl").
-include("common.hrl").

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-type mod_state() :: #{
    q => binary(),
    chan => pid(),
    chan_msg_id => integer(),           %% 当前信道ID
    max_confirmed_msg_id => integer(),  %% 已经确认的最大的信道ID
    wait_confirm => map(),              %% 当前信道待确认列表
    chan_ref => reference()
}.
-export_type([mod_state/0]).

%% @doc: Callback for starting from poolboy
start_link(Args) ->
    gen_server:start_link(?MODULE, [Args], []).

init([_]) ->
    process_flag(trap_exit, true),

    ?print("pid=~p", [self()]),
    State = #{chan_msg_id => 1, max_confirmed_msg_id => 0, wait_confirm => #{}},
    State1 = reset_chan(State),
    {ok, State1}.

handle_call({publish, Publish, Content}, From, #{chan := Channel} = State) ->
    case catch amqp_channel:call(Channel, Publish, Content) of
        ok ->
            #{chan_msg_id := MsgId, wait_confirm := Waits} = State,
            {FromPid, _Tag} = From,
            State1 = State#{chan_msg_id => MsgId+1, wait_confirm => Waits#{MsgId => FromPid}},
            {reply, {ok, MsgId}, State1};

        Result when (Result =:= blocked) orelse (Result =:= closing) ->
            {reply, channel_busy, State};

        ExitReply ->
            {reply, ExitReply, State}
    end;
handle_call(Request, _From, State) ->
    ?warning("unknown request: ~p", [Request]),
    {noreply, State}.

handle_cast(Msg, State) ->
    ?warning("unknown msg: ~p", [Msg]),
    {noreply, State}.

handle_info({'EXIT',FromPid,Reason}, #{chan := FromPid} = State) ->
    ?info("channel exit: ~p, ~p", [FromPid, Reason]),
    catch amqp_channel:close(FromPid),
    erlang:send_after(3000, self(), {reconnect}),
    State1 = close_channel(State),
    {noreply, State1};

handle_info({reconnect}, #{} = State) ->
    Channel = maps:get(chan, State, ?undefined),
    case is_pid(Channel) andalso is_process_alive(Channel) of
        true ->
            {noreply, State};
        false ->
            State1 = reset_chan(State),
            {noreply, State1}
    end;

handle_info(stop, State) ->
    {stop, normal, State};

handle_info(Info, State) ->
    ?warning("unknown info: ~p", [Info]),
    {noreply, State}.

terminate(_Reason, State) ->
%%    ?print("~p", [Channel]),
    close_channel(State),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% reset rabbitmq channel
reset_chan(#{} = State) ->
    case amqp_mylib:get_conn() of
        {ok, Connection1} ->
            case amqp_connection:open_channel(Connection1) of
                {ok, Channel1} ->
                    ?info("reset_chan:~p", [Channel1]),
                    link(Channel1),

                    case amqp_channel:call(Channel1, #'confirm.select'{}) of
                        #'confirm.select_ok'{} ->
                            amqp_channel:register_confirm_handler(Channel1, self()),
                            State#{chan => Channel1};

                        _ ->
                            catch amqp_channel:close(Channel1),
                            unlink(Channel1),
                            timer:sleep(1000),
                            reset_chan(State)
                    end;

                _ ->
                    erlang:send_after(3000, self(), {reconnect}),
                    State
            end;

        {error, _} ->
            erlang:send_after(3000, self(), {reconnect}),
            State
    end.

%% 关闭信道及处理相关内容
close_channel(#{chan := Channel, wait_confirm := Wait} = State) ->
    catch amqp_channel:close(Channel),
    lists:foreach(
        fun(Pid) ->
            gen_server:reply(Pid, delay_try_this_loop)
        end,
        maps:values(Wait)
    ),
    State#{chan_msg_id => 1, max_confirmed_msg_id => 0, wait_confirm => #{}}.
