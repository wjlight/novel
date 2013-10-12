#encoding:utf-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Article

	def initialize
		@perHelp = PersistenceHelp.new
	end

	def start(url, pre, db_name)
		chapter = page_parse(url)
		list = getAllNotReadingChatpersNum(chapter, db_name)
		list.each do |one|
			art_url = pre + one
			download_image(art_url)	
		end
		p "finish"
	end

	def page_parse(url)
		chapter = []
		begin
			html = open(URI.parse(url))
			page = Nokogiri::HTML(html)
			page.encoding = 'utf-8'
			links = page.css("a")
			puts "length:#{links.length}"
			links.each do |link|
			href = link["href"]
			is = Util.isArticalUrl(href)
			if is
				chapter.push(is)
			end
		end		
	rescue Exception => e
		print "error:", e.message
	end
	chapter
end	


def getAllNotReadingChatpersNum(chapter_all, db_name)
	not_read = []
	last_name = @perHelp.getLastGetNum(db_name)
	puts "dbName #{db_name},last_name #{last_name}\n"
	if(last_name == nil or last_name.strip == "")
		not_read = Util.getLastNew5(chapter_all)
		@perHelp.writeLastGetNum(db_name, not_read[0])
		return not_read
	end
	chapter_all = chapter_all.reverse
	chapter_all.each do |one|
		puts "one #{one}"
		if last_name.chomp == one.chomp
			puts "equal ............"
			break
		end
		not_read.push(one)
	end
	if not_read == []
		not_read.push(chapter_all[0])
	end
	@perHelp.writeLastGetNum(db_name, not_read[0])
	return not_read
end

def download_image(image_url)
	file_dir = "E://rubyWork//"

	dir = Util.get_art_id(image_url)
	image_dir = file_dir + turn_to_dir_name(dir[0])
	@perHelp.create_dir(image_dir)
	@perHelp.clear_old_file(image_dir)

	data=open(image_url){|f|f.read}
	p image_dir
	open(image_dir + "/"+ dir[1],"wb"){|f|f.write(data)} 
end


	# def get_image_url(art_url)
	# 	img_array = []
	# 	p "art_url:#{art_url}"
	# 	html = open(URI.parse(art_url))
	# 	page = Nokogiri::HTML(html)
	# 	page.encoding = 'utf-8'
	# 	links = page.css("img")
	# 	p links.length
	# 	return if links.length < 2
	# 	links.each do |link|
	# 		l = link["src"]
	# 		if l and l.include?"http://img1.ranwen.net/"
	# 			img_array.push(l)
	# 			p l
	# 		end
	# 	end
	# 	return img_array
	# end

	# def get_content_url(art_url)
	# 	html = open(art_url).read
	# 	p html.encoding
	# 	page = Nokogiri::HTML(html, nil, 'GBK')
	# 	# page = Iconv.iconv("UTF-8//IGNORE", "GBK//IGNORE", page)
	# 	# puts pag
	# 	xpaths = "//table//table//div"
	# 	begin
	# 		page.xpath(xpaths).each do |link|
	# 			p 'in'
	# 			puts link.text
	# 		end	
	# 	rescue Exception => e
	# 		p e.message
	# 	end
	# 	p 'finde'
	# end


	# def deal_image_content(images)
	# 	images.each do |image|
	# 		download_image(image)
	# 	end
	# end

	def turn_to_dir_name(url)
		if url == "13799"
			return "Sheng_tang"
		end
		if url == "17926"
			return "Mang_huang"
		end
		if url == "18330"
			return "Sheng_xie"
		end
	end
end

class PersistenceHelp
	def writeLastGetNum(file_name, last_num)
		create_db_file(file_name)
		file = File.open(file_name,"w") do |file|
			puts "write last num #{last_num}"
			file.puts last_num
		end
	end

	def create_dir(image_dir)
		if File.exist?(image_dir)
		else
			Dir.mkdir(image_dir)
		end
	end

	def create_db_file(file_name)
		if !File.exist?(file_name)
			puts "create new db file: #{file_name}"
			File.new(file_name,"w")
		end
	end

	#得到上次的看到的最后一章的num，从配置文件中拿到
	def getLastGetNum(file_name) 
		create_db_file(file_name)
		num = ""
		file = File.open(file_name, "r") do |file|
			while line = file.gets
				return line
			end
		end
	end

	def clear_old_file(dir_path)
		now_day = Time.now.day
		if File.directory? dir_path
			Dir.foreach(dir_path) do |file|
				if file != "." and file != ".."
					file_path = dir_path + "/" +file
					old_day = File.mtime(file_path).day
					if old_day != now_day
						File.delete(file_path)
					end
				end
			end
		end
	end

end

class Util
	def self.isArticalUrl(str)
		matched = /^[\d]+.html/.match(str)
		# matched = ARTICAL_MATCH
		if(matched and matched.length != 0)
			return matched[0]
		end
	end

	def self.getLastNew5(chapter, count = 2)
		chapter = chapter.compact
		chapter = chapter.reverse
		chapter5 = chapter.slice(0,count)
	end

	def self.get_art_id(image_url)
		image_url.split('/').last(2)
	end

end

if __FILE__ == $0
  	# your code
  	SHEN_TANG_PRE = "http://www.ranwen.net/files/article/13/13799/"
  	SHEN_TANG_URL = SHEN_TANG_PRE + "index.html"

  	RANWEN_URL = "http://www.ranwen.net"

  	SHENG_XIE_PRE = "http://www.ranwen.net/files/article/18/18330/"
  	SHENG_XIE_URL = SHENG_XIE_PRE + "index.html"

  	MangHuang_PRE = "http://www.ranwen.net/files/article/17/17926/"
  	MangHuang_URL = MangHuang_PRE + "index.html"

  	xie_db_name = "E://rubyWork//xie_db.txt"
  	tang_db_name = "E://rubyWork//tang_db.txt"
  	mang_db_name = "E://rubyWork//mang_db.txt"

  	article = Article.new
	# article.start(SHEN_TANG_URL, SHEN_TANG_PRE, tang_db_name)
	article.start(SHENG_XIE_URL, SHENG_XIE_PRE, xie_db_name)
	article.start(MangHuang_URL, MangHuang_PRE, mang_db_name)
end

