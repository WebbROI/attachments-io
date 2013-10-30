ActiveAdmin.register_page 'Dashboard' do

  menu priority: 0

  content do
    columns do
      column do
        panel 'Users' do
          para 'Hello, guys ;)'
        end
      end

      column do
        panel 'Synchronizations' do
          para 'Hi!'
        end
      end
    end
  end
end
