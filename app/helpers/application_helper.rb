module ApplicationHelper
  def valid_url?(url)
    return false unless url.respond_to?(:match?)
    url.match? URI.regexp(%w[http https])
  end

  def force_https(url)
    return url unless valid_url?(url)
    uri = URI.parse(url)
    uri.scheme = 'https'
    uri.to_s
  end
end
