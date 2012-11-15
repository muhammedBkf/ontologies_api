require_relative "linked_data_media_types"

class LinkedDataSerializer
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    # Get params
    params = env["rack.request.query_hash"]
    # Client accept header
    accept = env['rack-accept.request']
    # Out of the media types we offer, which would be best?
    best = LinkedDataMediaTypes.base_type(accept.best_media_type(LinkedDataMediaTypes.all))
    # If user provided a format, override the accept header
    best = params["format"].to_sym if params["format"]
    # Error out if we don't support the foramt
    unless LinkedDataMediaTypes.supported_base_type?(best)
      return response(:status => 415)
    end
    begin
      response(
        :status => status,
        :content_type => "#{LinkedDataMediaTypes.media_type_from_base(best)};charset=utf-8",
        :body => serialize(best, response, params)
      )
    rescue Exception => e
      response(:status => 500)
    end
  end

  private

  def response(options = {})
    status = options[:status] ||= 200
    headers = options[:headers] ||= {}
    body = options[:body] ||= ""
    content_type = options[:content_type] ||= "text/plain"
    content_length = options[:content_length] ||= body.bytesize.to_s
    raise ArgumentError("Body must be a string") unless body.kind_of?(String)
    headers.merge!({"Content-Type" => content_type, "Content-Length" => content_length})
    [status, headers, body]
  end

  def serialize(type, obj, params)
    only = params[:include] ||= []
    options = {:only => only}
    send("serialize_#{type}", obj, options)
  end

  def serialize_json(obj, options = {})
    obj.to_flex_hash(options).to_json
  end

  def serialize_html(obj, options = {})
    "html"
  end

  def serialize_xml(obj, options = {})
    "xml"
  end

  def serialize_turtle(obj, options = {})
    "turtle"
  end
end