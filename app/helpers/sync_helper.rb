module SyncHelper

  def sync_status_class_row(status)
    case status
      when UserSynchronization::STATUS_ERROR
        'negative'
      when UserSynchronization::STATUS_INPROCESS
        'warning'
      when UserSynchronization::STATUS_FINISHED
        'positive'
    end
  end

end
