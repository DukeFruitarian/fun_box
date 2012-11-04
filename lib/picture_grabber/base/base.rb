require "open-uri"
require "debugger"

module PictureGrabber
  # Класс PictureGrabber::Base парсит HTML страницу и скачивает рисунки
  #   заданных форматов
  class Base
    attr_accessor :formats

    # При инициализации можно задать массив форматов изображений для скачивания
    def initialize *formats
      @formats = formats.empty? ? ["jpg","png","jpeg","gif"] :
        formats.first.kind_of?(Array) ? formats.first : formats
      #debugger
      raise ArgumentError unless @formats.all?{|format| format.kind_of?(String)}
    end

    # Интерфейс для скачивания изображений. 2 необходимых параметра:
    #  - URL страницы для парсинга
    #  - поддиректория в директории images корневого каталога проекта.
    # Решил сделать подобным образом, вместо "#{Dir.home}/images"
    def grab url_, dir
      raise ArgumentError, "wrong URL" unless url_.kind_of?(String)
      raise ArgumentError, "wrong name of subdirectory" unless dir.kind_of?(String)
      # Проверяем на наличие протокола
      url = url_.match(/\Ahttp:\/\//) ? url_ : "http:\/\/" + url_
      #debugger
      # Создание при отсутствии и переход в указанную в параметрах директорию
      Dir.chdir(File.dirname(__FILE__))
      Dir.chdir("../../..")
      Dir.mkdir("images") unless File.directory?("images")
      Dir.chdir("images")
      Dir.mkdir(dir) unless File.directory?(dir)
      Dir.chdir(dir)

      # Запись HTML кода страницы в переменную
      html = ""
      open(url) do |s|
        s.each_line{|line| html << line}
      end

      # Сканирование страницы на наличие тегов img, получение ссылки на изображение
      imgs = html.scan(/<img.*src="([^"]*(?:#{formats.join('|')})[^"]*)"[^>]*/).flatten

      # Для каждой ссылки на изображение создаётся массив, содержащий
      #   полный путь к изображению и имя для сохранения
      imgs = imgs.map do |img_url|
        # если это относительная ссылка - добавляем URL страницы
        full_path = img_url.match(/\Ahttp[s]?:\/\//) ? img_url : url+img_url
        # если последний символ в ссылке "/", то удаляем его
        img_url.chop! if img_url[-1] == "/"
        # Получаем имя файла - всё с конца ссылки до символа "/"
        img_name = img_url.slice(/([^\/]*)\z/)
        [full_path,img_name]
      end

      imgs.each do |info|
        # Для каждого изображения создаётся поток для скачивания
        # Здесь можно добавить функционал ограничения коичества потоков.
        Thread.new do
          begin
            # В заданной директории открываем файл для бинарной записи
            File.open("#{Dir.getwd}/#{info.last}", 'wb') do |f|
              # считываем изображение в файл
              f.write open(info.first).read
            end
          # Перехватываем возможное исключение, вызванное ошибкой в потоке
          rescue Exception => e
            puts "#{info.first} - #{e}"
          end
        end
      end
      # Ожидаем окончания выполнения потоков
      Thread.list.each{|th| th.join unless th==Thread.current}
    end
  end
end
