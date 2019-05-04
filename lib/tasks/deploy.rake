desc 'Deployment tasks'
namespace :deploy do
  desc 'Deploy production environment'
  task production: :environment do
    sh 'ansible-playbook -i deploy/production/hosts deploy/production/production.yml'
  end
end
