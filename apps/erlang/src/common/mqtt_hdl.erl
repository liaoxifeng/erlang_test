%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 三月 2019 下午7:38
%%%-------------------------------------------------------------------

-module(mqtt_hdl).

-author("feng.liao").

%% API
-export([publish/2, publish/1]).

publish(CmdBinary) ->
    {ok, Topic} = application:get_env(erlang_test, c2s_topic),
    gen_server:cast(mqtt_publisher, {publish, Topic, CmdBinary}).

publish(Topic, CmdBinary) ->
    gen_server:cast(mqtt_publisher, {publish, Topic, CmdBinary}).
