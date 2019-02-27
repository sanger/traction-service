module RequestHeaders
  
  def json_api_headers
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end
end