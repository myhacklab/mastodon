class RemoveStatusService < BaseService
  def call(status)
    remove_from_self(status) if status.account.local?
    remove_from_followers(status)
    remove_from_mentioned(status)
    remove_reblogs(status)

    status.destroy!
  end

  private

  def remove_from_self(status)
    unpush(:home, status.account, status)
  end

  def remove_from_followers(status)
    status.account.followers.each do |follower|
      next unless follower.local?
      unpush(:home, follower, status)
    end
  end

  def remove_from_mentioned(status)
    status.mentions.each do |mention|
      mentioned_account = mention.account

      if mentioned_account.local?
        unpush(:mentions, mentioned_account, status)
      else
        send_delete_salmon(mentioned_account, status)
      end
    end
  end

  def send_delete_salmon(account, status)
    return unless status.local?
    NotificationWorker.perform_async(status.stream_entry.id, account.id)
  end

  def remove_reblogs(status)
    status.reblogs.each do |reblog|
      RemoveStatusService.new.call(reblog)
    end
  end

  def unpush(type, receiver, status)
    redis.zremrangebyscore(FeedManager.instance.key(type, receiver.id), status.id, status.id)
    FeedManager.instance.broadcast(receiver.id, type: 'delete', id: status.id)
  end

  def redis
    $redis
  end
end
