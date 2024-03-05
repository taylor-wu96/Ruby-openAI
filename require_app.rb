# frozen_string_literal: true

def require_app(folders = %w[environments lib models controllers])
  rb_list = Array(folders).flatten.join(',')
  Dir.glob("./{#{rb_list}}/**/*.rb").each do |file|
    require_relative file
  end
end
