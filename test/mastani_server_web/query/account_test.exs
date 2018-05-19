defmodule MastaniServer.Test.Query.AccountTest do
  # use MastaniServer.DataCase
  use MastaniServerWeb.ConnCase, async: true

  import Helper.Utils, only: [get_config: 2]
  import MastaniServer.Factory
  import MastaniServer.Test.ConnSimulator
  import MastaniServer.Test.AssertHelper
  import ShortMaps

  alias MastaniServer.{Accounts, CMS}

  @default_subscribed_communities get_config(:general, :default_subscribed_communities)

  setup do
    {:ok, user} = db_insert(:user)
    guest_conn = simu_conn(:guest)

    {:ok, ~m(guest_conn user)a}
  end

  describe "[account test]" do
    @query """
    query user($id: ID!) {
      user(id: $id) {
        id
        nickname
        bio
      }
    }
    """
    test "guest user can get specific user by user's id", ~m(guest_conn user)a do
      variables = %{id: user.id}
      results = guest_conn |> query_result(@query, variables, "user")
      assert results["id"] == to_string(user.id)
      assert results["nickname"] == user.nickname
    end

    @query """
    query pagedUsers($filter: PagedUsersFilter!) {
      pagedUsers(filter: $filter) {
        entries {
          id
          nickname
          bio
        }
        totalPages
        totalCount
        pageSize
        pageNumber
      }
    }
    """
    test "guest user can get paged users", ~m(guest_conn)a do
      variables = %{filter: %{page: 1, size: 10}}

      results = guest_conn |> query_result(@query, variables, "pagedUsers")
      assert results |> is_valid_pagination?()
    end
  end

  describe "[account subscrube]" do
    @query """
    query user($id: ID!) {
      user(id: $id) {
        id
        nickname
        subscribedCommunitiesCount
        subscribedCommunities {
          id
          title
        }
      }
    }
    """
    test "gest user can get subscrubed community list and count", ~m(guest_conn user)a do
      variables = %{id: user.id}
      {:ok, communities} = db_insert_multi(:community, inner_page_size())

      Enum.each(
        communities,
        &CMS.subscribe_community(%Accounts.User{id: user.id}, %CMS.Community{id: &1.id})
      )

      results = guest_conn |> query_result(@query, variables, "user")
      subscribedCommunities = results["subscribedCommunities"]
      subscribedCommunitiesCount = results["subscribedCommunitiesCount"]
      [community_1, community_2, community_3, community_x] = communities |> firstn_and_last(3)

      assert subscribedCommunities |> Enum.any?(&(&1["id"] == to_string(community_1.id)))
      assert subscribedCommunities |> Enum.any?(&(&1["id"] == to_string(community_2.id)))
      assert subscribedCommunities |> Enum.any?(&(&1["id"] == to_string(community_3.id)))
      assert subscribedCommunities |> Enum.any?(&(&1["id"] == to_string(community_x.id)))
      assert subscribedCommunitiesCount == inner_page_size()
    end

    test "gest user can get subscrubed communities count of 20 at most", ~m(guest_conn user)a do
      variables = %{id: user.id}
      {:ok, communities} = db_insert_multi(:community, inner_page_size() + 1)

      Enum.each(
        communities,
        &CMS.subscribe_community(%Accounts.User{id: user.id}, %CMS.Community{id: &1.id})
      )

      results = guest_conn |> query_result(@query, variables, "user")
      subscribedCommunities = results["subscribedCommunities"]

      assert length(subscribedCommunities) == inner_page_size()
    end

    @query """
    query subscribedCommunities($filter: PagedFilter!) {
      subscribedCommunities(filter: $filter) {
        entries {
          title
        }
        totalCount
        totalPages
        pageSize
        pageNumber
      }
    }
    """
    test "gest user can get paged default subscrubed communities", ~m(guest_conn)a do
      {:ok, _} = db_insert_multi(:community, 25)

      variables = %{filter: %{page: 1, size: 10}}
      results = guest_conn |> query_result(@query, variables, "subscribedCommunities")

      assert results |> is_valid_pagination?
      assert @default_subscribed_communities == results["pageSize"]
    end

    @query """
    query subscribedCommunities($userId: String, $filter: PagedFilter!) {
      subscribedCommunities(userId: $userId, filter: $filter) {
        entries {
          title
        }
        totalCount
        totalPages
        pageSize
        pageNumber
      }
    }
    """
    test "gest user can get paged default subscrubed communities with empty args",
         ~m(guest_conn)a do
      {:ok, _} = db_insert_multi(:community, 25)

      variables = %{userId: "", filter: %{page: 1, size: 10}}
      results = guest_conn |> query_result(@query, variables, "subscribedCommunities")

      assert results |> is_valid_pagination?
      assert @default_subscribed_communities == results["pageSize"]
    end
  end
end
