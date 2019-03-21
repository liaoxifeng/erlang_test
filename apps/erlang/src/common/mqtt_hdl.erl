%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 三月 2019 下午7:38
%%%-------------------------------------------------------------------

-module(mqtt_hdl).
-include("common.hrl").
-author("feng.liao").

%% API
-export([publish/2, publish/1, call/1, call/2]).

call(CmdContent) ->
    call(CmdContent, 5000).

call(CmdContent, 5000) ->
    {ok, Topic} = application:get_env(erlang_test, c2s_topic),
    Tag = util:unixtime_microsecond(),
    ets:insert(?ets_mqtt_call, {Tag, self()}),
    CmdBinary = jsx:encode([{tag, Tag}|CmdContent]),
    publish(Topic, CmdBinary),
    receive
        {async_msg, Reply} ->
            ets:delete(?ets_mqtt_call, Tag),
            {ok, Reply}

    after 5000 ->
        {error, timeout}
    end.

publish(CmdBinary) ->
    {ok, Topic} = application:get_env(erlang_test, c2s_topic),
    emqttc:publish(whereis(publisher), Topic, CmdBinary, [{qos, 2}]).

publish(Topic, CmdBinary) ->
    emqttc:publish(whereis(publisher), Topic, CmdBinary, [{qos, 2}]).
