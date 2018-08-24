defmodule MastaniServer.Accounts do
  @moduledoc false

  alias MastaniServer.Accounts.Delegate.{
    Achievements,
    Billing,
    Customization,
    Fans,
    FavoriteCategory,
    Mails,
    Profile,
    ReactedContents
  }

  # profile
  defdelegate update_profile(user, attrs), to: Profile
  defdelegate github_signin(github_user), to: Profile
  defdelegate default_subscribed_communities(filter), to: Profile
  defdelegate subscribed_communities(user, filter), to: Profile

  # favorite category
  defdelegate list_favorite_categories(user, opt, filter), to: FavoriteCategory
  defdelegate create_favorite_category(user, attrs), to: FavoriteCategory
  defdelegate update_favorite_category(user, attrs), to: FavoriteCategory
  defdelegate delete_favorite_category(user, id), to: FavoriteCategory
  defdelegate set_favorites(user, thread, content_id, category_title), to: FavoriteCategory
  defdelegate unset_favorites(user, thread, content_id, category_title), to: FavoriteCategory

  # achievement
  defdelegate achieve(user, operation, key), to: Achievements

  # fans
  defdelegate follow(user, follower), to: Fans
  defdelegate undo_follow(user, follower), to: Fans
  defdelegate fetch_followers(user, filter), to: Fans
  defdelegate fetch_followings(user, filter), to: Fans

  # reacted contents
  defdelegate reacted_contents(thread, react, filter, user), to: ReactedContents

  # mentions
  defdelegate fetch_mentions(user, filter), to: Mails

  # notifications
  defdelegate fetch_notifications(user, filter), to: Mails
  defdelegate fetch_sys_notifications(user, filter), to: Mails

  # common message
  defdelegate mailbox_status(user), to: Mails
  defdelegate mark_mail_read_all(user, opt), to: Mails
  defdelegate mark_mail_read(mail, user), to: Mails

  # purchase
  defdelegate purchase_service(user, key, value), to: Billing
  defdelegate purchase_service(user, key), to: Billing
  defdelegate has_purchased?(user, key), to: Billing

  # customization
  defdelegate add_custom_setting(user, key, value), to: Customization
  defdelegate add_custom_setting(user, key), to: Customization
end
