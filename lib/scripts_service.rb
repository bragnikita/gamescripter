require_relative 'service_helpers'
require_relative 'models/script'
require 'gamescript_creator'

class ScriptOperations

  def initialize()
    @default_script_version = 'v0.1'
  end

  def create(params)
    s = Script.new(params)
    # create attachmens folder
    # set up default version, attachments folder
    s.save!
    s
  end

  def update(id, params)
    Script.params.find(id).update_attributes!(params)
  end

  def delete(id)
    Script.params.find(id).destroy!
  end

  def save_content(id, content)
    Script.find(id).update_attributes!(source: content)
  end

  def update_content(id, content)
    script = Script.find(id)
    script.update_attributes!(source: content)
    stack = GamescriptCreator::build_stack (script.version || @default_script_version)
    io = Tempfile.new(id, :encoding => 'UTF-8')
    begin
      io.write content
      io.rewind
      html = stack.create_task.process(io)
      script.update_attributes!(html: html)
      return html
    rescue GamescriptCreator::ScriptParserError => e
      raise ScriptProcessingError.new(e.message)
    ensure
      io && io.close && io.unlink
    end
  end

  def preview(content)
    version = content[:version]
    stack = GamescriptCreator::build_stack (version || @default_script_version)
    io = Tempfile.new("script_preview", :encoding => 'UTF-8')
    begin
      io.write content[:source]
      io.rewind
      html = stack.create_task.process(io)
      return html
    rescue GamescriptCreator::ScriptParserError => e
      raise ScriptProcessingError.new(e.message)
    ensure
      io && io.close && io.unlink
    end
  end

  def upload_image(script_id)
    # carrierwave
  end

  def list_images(script_id)
    Script.params.find(script_id).images
  end

  def get_params(script_id)
    Script.params.find(script_id)
  end

  def get_with_source(script_id)
    Script.with_source.find(script_id)
  end

  def get_html(script_id)
    Script.only(:html).find(script_id).html
  end

end
