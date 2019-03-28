%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 接收cfg下文件的变动，并且动态编译
%%% @end
%%% Created : 09. 三月 2019 下午7:46
%%%-------------------------------------------------------------------

-module(cfg_loader).
-author("feng.liao").

-behaviour(gen_server).

-include("common.hrl").

%% API
-export([start_link/1,start/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    case lists:keymember(fs, 1, application:loaded_applications()) of
        false ->
            ignore;
        true ->
            start_link([default_fs])
    end.

start_link(Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Args, []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Name]) ->
    fs:subscribe(Name),
    {ok, IncludePath} = application:get_env(fs, include_path),
    Include = filename:absname(IncludePath),
    ?INF("cfg_loader start"),
    {ok, #{include => Include}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({_Pid, {fs, file_event}, {Path, Flags}}, #{include := Include} = State) ->

    case filename:extension(Path) of
        ".erl" ->
            case Flags of
                [deleted] ->
                    ok;
                _ ->
                    {ok, Module, Binary, _Warnings} =
                        compile:file(Path, [binary, return, {i, [Include]}]),
                    code:load_binary(Module, Path, Binary),
                    ?INF("reload ~p", [Path]),
                    ok
            end;
        _ ->
            ok
    end,
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
