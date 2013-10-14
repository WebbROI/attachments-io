module ApplicationHelper
  def semantic_class_for(flash_type)
    case flash_type
      when :success
        'success'
      when :error
        'error'
      when :alert
        'yellow'
      when :notice
        'blue'
      else
        flash_type.to_s
    end
  end
end
