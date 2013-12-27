ActiveAdmin.register_page 'Synchronizations' do

  menu priority: 1

  page_action :fix, method: :post do
    UserSynchronization.fix_problematic
    redirect_to admin_synchronizations_path, notice: 'Fixed!'
  end

  sidebar :info do
    para raw "Synchronizations in process: <strong>#{UserSynchronization.inprocess.count}</strong>"
    para raw "Waiting synchronzation: <strong>#{UserSynchronization.waiting.count}</strong>"
  end

  content do
    problematic = UserSynchronization.problematic.count

    h2 'User with problems'
    if  problematic.zero?
      para 'No problematic users. Good job!'
    else
      span raw "Problematic users: <strong>#{problematic}</strong>"
      span link_to 'fix it', admin_synchronizations_fix_path, method: :post
    end
  end

end