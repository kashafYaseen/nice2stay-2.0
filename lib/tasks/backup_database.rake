namespace :db do
  desc "generate database backup"
  task :backup do |t, args|
    datestamp = Time.current.strftime('%d-%m-%Y-%H-%M-%S')
    backup_folder = Rails.env.development? ? File.join(Rails.root, 'backups') : ENV['DATABASE_BACKUP_PATH']
    dir = Dir.new(backup_folder)
    index = dir_entries(dir).last.to_s.split('-')[2].to_i.next
    `PGPASSWORD='#{ENV['NICE2STAY_DATABASE_PASSWORD']}' pg_dump -U #{ENV['NICE2STAY_DATABASE_USER']} -h localhost #{ENV['NICE2STAY_DATABASE_NAME']} -f #{backup_folder}/database-dump-#{index}-#{datestamp}.sql`
    FileUtils.rm_rf(File.join(backup_folder, dir_entries(dir).first))  if dir_entries(dir).size > 4
    puts "Database backup created successfully -------------------------------->> #{datestamp}"
  end

  def dir_entries(dir)
    dir.entries.reject { |entry| entry == '.' || entry == '..' }.sort_by{|v| v.split("-")[2].to_i}
  end
end
