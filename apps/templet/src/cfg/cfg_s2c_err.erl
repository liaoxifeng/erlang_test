-module(cfg_s2c_err).

-compile([export_all, nowarn_export_all]).



%% 错误码
%% 0
get_msg('E_S2CErrCode_Succ') -> <<"成功"/utf8>>;
            
%% 1
get_msg('E_S2CErrCode_Sys') -> <<"系统错误"/utf8>>;
            
%% 2
get_msg('E_S2CErrCode_Busy') -> <<"系统繁忙"/utf8>>;
            
%% 3
get_msg('E_S2CErrCode_OpToFrequency') -> <<"操作过于频繁"/utf8>>;
            
%% 4
get_msg('E_S2CErrCode_ReLogin') -> <<"您在别处登录"/utf8>>;
            
%% 5
get_msg('E_S2CErrCode_NotLogin') -> <<"未登录，请先登录"/utf8>>;
            
%% 6
get_msg('E_S2CErrCode_LoginCheckTimeout') -> <<"登录验证超时"/utf8>>;
            
%% 7
get_msg('E_S2CErrCode_LoginCheckNotThrough') -> <<"登录验证不通过"/utf8>>;
            
%% 8
get_msg('E_S2CErrCode_ErrArgs') -> <<"参数错误"/utf8>>;
            
%% 9
get_msg('E_S2CErrCode_ProtoErr') -> <<"协议解析错误"/utf8>>;
            
%% 10
get_msg('E_S2CErrCode_LoginTokenInvalid') -> <<"登录token无效"/utf8>>;
            
%% 11
get_msg('E_S2CErrCode_BeKicked') -> <<"您已经被踢下线"/utf8>>;
            
%% 12
get_msg('E_S2CErrCode_Gs_Maintenance') -> <<"服务器维护中"/utf8>>;
            
%% 100
get_msg('E_S2CErrCode_NotEnoughMoney') -> <<"余额不足"/utf8>>;
            
%% 101
get_msg('E_S2CErrCode_RoomNotExist ') -> <<"房间不存在"/utf8>>;
            
%% 102
get_msg('E_S2CErrCode_NotInRoom ') -> <<"玩家不在房间"/utf8>>;
            
%% 103
get_msg('E_S2CErrCode_OutOfLimit ') -> <<"超出最大值"/utf8>>;
            
%% 104
get_msg('E_S2CErrCode_CanNotBet') -> <<"下注时间已过"/utf8>>;
            

%%================================================
get_msg(_) -> <<"未知错误"/utf8>>.


%%================================================
