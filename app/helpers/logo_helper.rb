# frozen_string_literal: true

module LogoHelper
  def logo=(file_uploaded)
    if file_uploaded.class != Hash
      image = MiniMagick::Image.open(file_uploaded.tempfile.path)
      image.resize "x140"
      ImageOptimizer.new(image.path).optimize
      file_uploaded.tempfile = image.tempfile
    end
    super(file_uploaded)
  end
end
