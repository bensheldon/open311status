json.array!(@cities) do |city|
  json.extract! city, :id, :slug
  json.url city_url(city, format: :json)
end
