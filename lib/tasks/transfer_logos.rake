desc 'transfer logo from files to database'
task transfer_logos: :environment do
  (Institution.all + Antenne.all).each do |entity|
    name = entity.to_s.parameterize
    possible_paths = "public/images/institutions/#{name}.png", "public/images/institutions/#{name}.jpg"
    file_path = ''
    possible_paths.each do |path|
      if File.file?(path)
        file_path = path
      end
    end

    if file_path.present?
      entity.logo.attach(io: File.open(file_path), filename: "#{name}.png")
    end
  end
end
