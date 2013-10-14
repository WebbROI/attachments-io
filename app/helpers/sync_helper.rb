module SyncHelper

  def sync_status_class(status)
    case status
      when 0
        'negative'
      when 1
        'warning'
      when 2
        'positive'
    end
  end

end
