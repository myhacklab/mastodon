class PrecomputeFeedService < BaseService
  # Fill up a user's home/mentions feed from DB and return a subset
  # @param [Symbol] type :home or :mentions
  # @param [Account] account
  # @return [Array]
  def call(type, account, limit)
    instant_return = []

    Status.send("as_#{type}_timeline", account).order('id desc').limit(FeedManager::MAX_ITEMS).find_each do |status|
      next if FeedManager.instance.filter?(type, status, account)
      redis.zadd(FeedManager.instance.key(type, account.id), status.id, status.id)
      instant_return << status unless instant_return.size > limit
    end

    instant_return
  end

  private

  def redis
    $redis
  end
end
