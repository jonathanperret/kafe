-module(kafe_consumer_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

-export([
         init_per_suite/1
         , end_per_suite/1
         , init_per_testcase/2
         , end_per_testcase/2
         , all/0
         , suite/0
        ]).

-export([
         t_consumer/1
        ]).

suite() ->
   [{timetrap, {seconds, 30}}].

init_per_suite(Config) ->
  application:ensure_all_started(kafe),
  Config.

end_per_suite(_Config) ->
  application:stop(kafe),
  ok.

init_per_testcase(_Case, Config) ->
  Config.

end_per_testcase(_Case, Config) ->
  Config.

all() ->
  [F||{F, _A} <- module_info(exports),
      case atom_to_list(F) of
        "t_" ++ _ -> true;
        _ -> false
      end].

t_consumer(_Config) ->
  get_coordinator(),

  {ok, #{error_code := none,
         generation_id := GenerationId,
         leader_id := _LeaderId,
         member_id := MemberId,
         members := _,
         protocol_group := <<"default_protocol">>}} =
  kafe:join_group(<<"kafe_test_consumer_group">>, #{session_timeout => 6000}),

  {ok, [#{error_code := none,
         group_id := <<"kafe_test_consumer_group">>,
         members := [#{client_host := ClientHost,
                       client_id := <<"kafe">>,
                       member_assignment := #{partition_assignment := [],
                                              user_data := <<>>,
                                              version := -1},
                       member_id := MemberId,
                       member_metadata := <<>>}],
         protocol := <<>>,
         protocol_type := <<"consumer">>,
         state := <<"AwaitingSync">>}]} =
  kafe:describe_group(<<"kafe_test_consumer_group">>),

  {ok, #{error_code := none,
         partition_assignment := PartitionAssignment,
         user_data := <<>>,
         version := 0}} =
  kafe:sync_group(<<"kafe_test_consumer_group">>, GenerationId, MemberId,
                  [#{member_id => MemberId,
                     member_assignment => #{}}]),
  check_partition_assignment(PartitionAssignment),

  ok = heartbeat(3, GenerationId, MemberId, ClientHost),

  {ok, #{error_code := none}} =
  kafe:leave_group(<<"kafe_test_consumer_group">>, MemberId).

heartbeat(0, _, _, _) ->
  ok;
heartbeat(N, GenerationId, MemberId, ClientHost) ->
  {ok, [#{error_code := none,
         group_id := <<"kafe_test_consumer_group">>,
         members := [#{client_host := ClientHost,
                       client_id := <<"kafe">>,
                       member_assignment := #{
                         partition_assignment := PartitionAssignment,
                         user_data := <<>>,
                         version := 0},
                       member_id := MemberId,
                       member_metadata := <<>>}],
         protocol := <<"default_protocol">>,
         protocol_type := <<"consumer">>,
         state := <<"Stable">>}]} =
  kafe:describe_group(<<"kafe_test_consumer_group">>),
  check_partition_assignment(PartitionAssignment),

  timer:sleep(2900),

  {ok, #{error_code := none}} = kafe:heartbeat(<<"kafe_test_consumer_group">>, GenerationId, MemberId),

  heartbeat(N - 1, GenerationId, MemberId, ClientHost).

check_partition_assignment(PartitionAssignment) ->
  true = lists:member(#{partitions => [0],
                        topic => <<"testone">>}, PartitionAssignment),
  true = lists:member(#{partitions => [2, 1, 0],
                        topic => <<"testthree">>}, PartitionAssignment),
  true = lists:member(#{partitions => [1, 0],
                        topic => <<"testtwo">>}, PartitionAssignment).

get_coordinator() ->
  case kafe:group_coordinator(<<"kafe_test_consumer_group">>) of
    {ok, #{error_code := group_coordinator_not_available}} ->
      timer:sleep(100),
      get_coordinator();
    {error, E} ->
      ?debugFmt("==> ERROR : ~p", [E]),
      erlang:exit(1);
    _ ->
      ok
  end.

