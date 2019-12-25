#!/usr/bin/ruby

require 'RMagick'

class Manager
	def initialize
		@color_map = [
			{ :pixel => Magick::Pixel.from_color('#000000'), :color => 0, :bright => 0 },

			{ :pixel => Magick::Pixel.from_color('#0000B0'), :color => 1, :bright => 0 },
			{ :pixel => Magick::Pixel.from_color('#B00000'), :color => 2, :bright => 0 },
			{ :pixel => Magick::Pixel.from_color('#B000B0'), :color => 3, :bright => 0 },
			{ :pixel => Magick::Pixel.from_color('#00B000'), :color => 4, :bright => 0 },
			{ :pixel => Magick::Pixel.from_color('#00B0B0'), :color => 5, :bright => 0 },
			{ :pixel => Magick::Pixel.from_color('#B0B000'), :color => 6, :bright => 0 },
			{ :pixel => Magick::Pixel.from_color('#B0B0B0'), :color => 7, :bright => 0 },

			{ :pixel => Magick::Pixel.from_color('#0000FF'), :color => 1, :bright => 1 },
			{ :pixel => Magick::Pixel.from_color('#FF0000'), :color => 2, :bright => 1 },
			{ :pixel => Magick::Pixel.from_color('#FF00FF'), :color => 3, :bright => 1 },
			{ :pixel => Magick::Pixel.from_color('#00FF00'), :color => 4, :bright => 1 },
			{ :pixel => Magick::Pixel.from_color('#00FFFF'), :color => 5, :bright => 1 },
			{ :pixel => Magick::Pixel.from_color('#FFFF00'), :color => 6, :bright => 1 },
			{ :pixel => Magick::Pixel.from_color('#FFFFFF'), :color => 7, :bright => 1 },
		]

		@color_hash = {}
		@color_map.each { |v| @color_hash[v[:pixel].to_color] = v }

		@colors_img = Magick::Image.new(@color_map.size, 1)

		@colors_img.view(0, 0, @colors_img.columns, @colors_img.rows) do |view|
			@color_map.each_with_index do |v, i|
				view[0][i] = v[:pixel]
			end
		end
	end

	def load(path)
		return Magick::ImageList.new(path)
			.normalize
			.remap(@colors_img, Magick::NoDitherMethod)
	end

	def convert(img)
		data = []

		img.each_pixel do |pixel, col, row|
			data << @color_hash[pixel.to_color][:color] * 4
		end

		return data
	end

	def save(path, data)
		File.open(path, 'wb') do |f|
			f << data.map { |v| v.chr }.join
		end
	end

	def manage
		if ARGV.size != 1
			puts "Usage: #{$0} <image-name>"
			return
		end

		prepared_img = load(ARGV[0])
		out_base = ARGV[0].gsub(/\.[^\.]+$/, '')

		# prepared_img.write(out_base + '-prepared.png')

		data = convert(prepared_img)
		save(out_base + '.dat', data)
	end
end

mng = Manager.new
mng.manage
