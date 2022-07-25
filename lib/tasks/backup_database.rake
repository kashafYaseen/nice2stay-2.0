namespace :db do
  desc "generate database backup"
  task :backup do |t, args|
    datestamp = Time.current.strftime('%d-%m-%Y-%H-%M-%S')
    backup_folder = Rails.env.development? ? File.join(Rails.root, 'backups') : ENV['DATABASE_BACKUP_PATH']
    `PGPASSWORD='#{ENV['NICE2STAY_DATABASE_PASSWORD']}' pg_dump -U #{ENV['NICE2STAY_DATABASE_USER']} -h localhost #{ENV['NICE2STAY_DATABASE_NAME']} -f #{backup_folder}/database-dump-#{datestamp}.sql`
    dir = Dir.new(backup_folder)
    all_backups = dir.entries.reject { |entry| entry == '.' || entry == '..' }.sort
    FileUtils.rm_rf(File.join(backup_folder, all_backups.first))  if all_backups.size > 4
    puts "Database backup created successfully -------------------------------->> #{datestamp}"
  end
end
