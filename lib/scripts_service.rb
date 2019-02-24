require_relative 'service_helpers'
require_relative 'models/script'
require 'gamescript_creator'

class ScriptOperations

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
    stack = GamescriptCreator::build_stack script.version
    io = Tempfile.new('id')
    begin
      io.write content
      io.rewind
      html = stack.create_task.process(io)
      script.update_attributes!(html: html)
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
