module ApplicationHelper
  def force_https(url)
    uri = URI.parse(url)
    uri.scheme = 'https'
    uri.to_s
  end
end
