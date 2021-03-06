%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% 管理机器人
%%% @end
%%% Created : 11. 九月 2018 上午9:57
%%%-------------------------------------------------------------------
-module(robot_mgr).
-author("feng.liao").

-include("common.hrl").
-include("all_pb.hrl").

-behaviour(gen_server).

-export([start_link/0, get_count/0, start/1, send/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-define(ets_robot, ets_robot).
-record(ets_robot, {
    id,
    pid :: pid()
}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% robot count
get_count() ->
    ets:info(?ets_robot, size).

init([]) ->
    ets:new(?ets_robot, [set, public, named_table, {keypos, #ets_robot.id}]),
    {ok, 0}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({add, Id, Pid}, State) ->
    ets:insert(?ets_robot, #ets_robot{id = Id, pid = Pid}),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

start(Id) ->
    {ok, Pid} = robot:start_link(Id),
    Register = #'C2S_Register'{use_name = <<"feng1">>, password = <<"234567">>, phone_number = <<"15172407849">>},
    Pid ! {binary, pt:encode_msg(Register)}.

%%
send(Id) ->
    {ok, Pid} = robot:start_link(Id),
    Msg = #'C2S_Login'{use_name = <<"feng">>, password = <<"passord">>},
    Pid ! {binary, pt:encode_msg(Msg)}.

