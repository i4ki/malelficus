# adapted from 
# https://github.com/mmonteleone/michaelmonteleone.net/blob/master/Rakefile
# and
# https://github.com/jbarratt/serialized.net/blob/master/Rakefile

require 'rake/clean'

desc 'Build site with Jekyll'
task :build => [:clean] do
  jekyll
end

desc 'Notify Google of the new sitemap'
task :sitemap do
  begin
    require 'net/http'
    require 'uri'
    puts '* Pinging Google about the sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape('http://tjstein.com/sitemap.xml'))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end
 
desc 'Start server with --auto'
task :server => [:clean]  do
  jekyll('--server --auto')
end

desc 'Deploy to production'
task :deploy do
  puts '* Publishing files to production server'
  sh "rsync -rtzh --delete _site/ --rsh='ssh -p43102' deploy@tjstein.com:/home/deploy/tjstein.com/public"
end

##
# Package Requirement:
# jpegoptim
# Install OSX:
# brew install jpegoptim
# Install Ubuntu:
# [apt-get | aptitude] install jpegoptim
#
desc 'Optimize JPG images in output/images directory using jpegoptim'
task :jpg do
  puts `find _site/images -name '*.jpg' -exec jpegoptim {} \\;`
end

##
# Package Requirement:
# optipng
# Install OSX:
# brew install optipng
# Install Ubuntu:
# [apt-get | aptitude] install optipng
#
desc 'Optimize PNG images in output/images directory using optipng'
task :png do
  puts `find _site/images -name '*.png' -exec optipng {} \\;`
end

desc 'Minify CSS & HTML'
task :minify do
  puts '* Minifying CSS and HTML'
  sh 'java -jar ~/.java/yuicompressor-2.4.2.jar --type css css/print.css -o _site/css/print.css'
  sh 'java -jar ~/.java/yuicompressor-2.4.2.jar --type css css/screen.css -o _site/css/screen.css'
  sh 'java -jar ~/.java/yuicompressor-2.4.2.jar --type css css/custom.css -o _site/css/custom.css'
  sh 'java -jar ~/.java/htmlcompressor-0.9.8.jar _site/index.html -o _site/index.html'
  sh 'java -jar ~/.java/htmlcompressor-0.9.8.jar --type=xml _site/sitemap.xml -o _site/sitemap.xml'
end

desc 'Backup to NAS + Amazon S3'
task :backup do
  puts '* Backing up to NAS + Amazon S3'
  puts `./backup.sh`
end

desc 'Push source code to Github'
task :push do
  puts '* Pushing to Github'
  puts `git push origin master`
end

desc 'List all draft posts'
task :drafts do
  puts `find ./_posts -type f -exec grep -H 'published: false' {} \\;`
end

desc 'Begin a new post'
task :post do   
  ROOT_DIR = File.dirname(__FILE__)

  title = ARGV[1]
  tags = ARGV[2 ]

  unless title
    puts %{Usage: rake post "The Post Title"}
    exit(-1)
  end

  datetime = Time.now.strftime('%Y-%m-%d')  # 30 minutes from now.
  slug = title.strip.downcase.gsub(/ /, '-')

  # E.g. 2006-07-16_11-41-batch-open-urls-from-clipboard.markdown
  path = "#{ROOT_DIR}/_posts/#{datetime}-#{slug}.markdown"

  header = <<-END
---
layout: post
title: #{title}
excerpt: 
comments: true
---

END

  File.open(path, 'w') {|f| f << header }
  system("mate", path)    
end  

task :default => :server

def jekyll(opts = '')
  sh 'time jekyll ' + opts
end