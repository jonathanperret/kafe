-module(kafe_protocol_join_group_tests).
-include_lib("eunit/include/eunit.hrl").
-include("../include/kafe.hrl").

kafe_protocol_join_group_tests_test_() ->
  {setup,
   fun() ->
       meck:new(kafe, [passthrough]),
       meck:expect(kafe, topics, 0, #{<<"testone">> => #{0 => "172.17.0.1:9094"},
                                      <<"testthree">> => #{0 => "172.17.0.1:9094", 1 => "172.17.0.1:9092", 2 => "172.17.0.1:9093"},
                                      <<"testtwo">> => #{0 => "172.17.0.1:9092", 1 => "172.17.0.1:9093"}}),
       ok
   end,
   fun(_) ->
       meck:unload(kafe),
       ok
   end,
   [
    fun() ->
        ?assertEqual(
           #{packet => <<0, 11, 0, 0, 0, 0, 0, 0, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 0, 117, 48, 0, 0, 0,
                         8, 99, 111, 110, 115, 117, 109, 101, 114, 0, 0, 0, 1, 0, 16, 100, 101, 102, 97, 117, 108, 116,
                         95, 112, 114, 111, 116, 111, 99, 111, 108, 0, 0, 0, 0, 0, 3, 0, 7, 116, 101, 115, 116, 111, 110,
                         101, 0, 9, 116, 101, 115, 116, 116, 104, 114, 101, 101, 0, 7, 116, 101, 115, 116, 116, 119,
                         111, 0, 0, 0, 0>>,
             state => #{api_key => ?JOIN_GROUP_REQUEST,
                        api_version => 0,
                        client_id => <<"test">>,
                        correlation_id => 1}},
           kafe_protocol_join_group:request(<<"test">>, #{}, #{api_key => ?JOIN_GROUP_REQUEST,
                                                               api_version => 0,
                                                               correlation_id => 0,
                                                               client_id => <<"test">>})),

        ?assertEqual(
           #{packet => <<0, 11, 0, 1, 0, 0, 0, 0, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 0, 117, 48, 0, 0,
                         234, 96, 0, 0, 0, 8, 99, 111, 110, 115, 117, 109, 101, 114, 0, 0, 0, 1, 0, 16, 100, 101, 102, 97,
                         117, 108, 116, 95, 112, 114, 111, 116, 111, 99, 111, 108, 0, 0, 0, 0, 0, 3, 0, 7, 116, 101, 115,
                         116, 111, 110, 101, 0, 9, 116, 101, 115, 116, 116, 104, 114, 101, 101, 0, 7, 116, 101, 115,
                         116, 116, 119, 111, 0, 0, 0, 0>>,
             state => #{api_key => ?JOIN_GROUP_REQUEST,
                        api_version => 1,
                        client_id => <<"test">>,
                        correlation_id => 1}},
           kafe_protocol_join_group:request(<<"test">>, #{}, #{api_key => ?JOIN_GROUP_REQUEST,
                                                               api_version => 1,
                                                               correlation_id => 0,
                                                               client_id => <<"test">>}))
    end,
    fun() ->
        ?assertEqual(
           {ok, #{error_code => none,
                 generation_id => 1,
                 leader_id => <<"kafe-9ca65ef4-65e8-4071-83e6-549862c173e0">>,
                 member_id => <<"kafe-9ca65ef4-65e8-4071-83e6-549862c173e0">>,
                 members => [#{member_id => <<"kafe-9ca65ef4-65e8-4071-83e6-549862c173e0">>,
                               member_metadata => <<>>}],
                 protocol_group => <<"default_protocol">>}},
           kafe_protocol_join_group:response(
             <<0, 0, 0, 0, 0, 1, 0, 16, 100, 101, 102, 97, 117, 108, 116, 95, 112, 114, 111, 116, 111, 99, 111, 108,
               0, 41, 107, 97, 102, 101, 45, 57, 99, 97, 54, 53, 101, 102, 52, 45, 54, 53, 101, 56, 45, 52, 48, 55,
               49, 45, 56, 51, 101, 54, 45, 53, 52, 57, 56, 54, 50, 99, 49, 55, 51, 101, 48, 0, 41, 107, 97, 102, 101,
               45, 57, 99, 97, 54, 53, 101, 102, 52, 45, 54, 53, 101, 56, 45, 52, 48, 55, 49, 45, 56, 51, 101, 54, 45,
               53, 52, 57, 56, 54, 50, 99, 49, 55, 51, 101, 48, 0, 0, 0, 1, 0, 41, 107, 97, 102, 101, 45, 57, 99, 97,
               54, 53, 101, 102, 52, 45, 54, 53, 101, 56, 45, 52, 48, 55, 49, 45, 56, 51, 101, 54, 45, 53, 52, 57, 56,
               54, 50, 99, 49, 55, 51, 101, 48, 0, 0, 0, 0>>,
             #{api_version => 0})),

        ?assertEqual(
           {ok, #{error_code => none,
                 generation_id => 1,
                 leader_id => <<"kafe-9ca65ef4-65e8-4071-83e6-549862c173e0">>,
                 member_id => <<"kafe-9ca65ef4-65e8-4071-83e6-549862c173e0">>,
                 members => [#{member_id => <<"kafe-9ca65ef4-65e8-4071-83e6-549862c173e0">>,
                               member_metadata => <<>>}],
                 protocol_group => <<"default_protocol">>}},
           kafe_protocol_join_group:response(
             <<0, 0, 0, 0, 0, 1, 0, 16, 100, 101, 102, 97, 117, 108, 116, 95, 112, 114, 111, 116, 111, 99, 111, 108,
               0, 41, 107, 97, 102, 101, 45, 57, 99, 97, 54, 53, 101, 102, 52, 45, 54, 53, 101, 56, 45, 52, 48, 55,
               49, 45, 56, 51, 101, 54, 45, 53, 52, 57, 56, 54, 50, 99, 49, 55, 51, 101, 48, 0, 41, 107, 97, 102, 101,
               45, 57, 99, 97, 54, 53, 101, 102, 52, 45, 54, 53, 101, 56, 45, 52, 48, 55, 49, 45, 56, 51, 101, 54, 45,
               53, 52, 57, 56, 54, 50, 99, 49, 55, 51, 101, 48, 0, 0, 0, 1, 0, 41, 107, 97, 102, 101, 45, 57, 99, 97,
               54, 53, 101, 102, 52, 45, 54, 53, 101, 56, 45, 52, 48, 55, 49, 45, 56, 51, 101, 54, 45, 53, 52, 57, 56,
               54, 50, 99, 49, 55, 51, 101, 48, 0, 0, 0, 0>>,
             #{api_version => 1}))
    end
   ]}.
