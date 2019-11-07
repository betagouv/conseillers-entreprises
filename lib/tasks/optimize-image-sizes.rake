desc 'optimize institutions images files'
task :optimize_image_sizes do
  institutions_images_path = 'app/assets/images/institutions/'
  sh "mogrify -resize 'x140' #{institutions_images_path}*.png #{institutions_images_path}*.jpg"
  sh "optipng -strip all #{institutions_images_path}*.png"
  sh "jpegoptim -s #{institutions_images_path}*.jpg"
end
